
using Mmap
using DimensionalData
using DimensionalData.Dimensions

@dim Samp YDim "Sample"
@dim Freq XDim "Frequency"

@doc "The frequency dimension of `Filterbank` data in MHz" Freq
@doc "The sample dimension of `Filterbank` data" Samp

const HEADER_VALUE_TYPE = Union{String,Real}

const HEADER_TYPES = Dict("filename" => String,
                          "telescope_id" => :int,
                          "telescope" => String,
                          "machine_id" => :int,
                          "data_type" => :int,
                          "rawdatafile" => String,
                          "source_name" => String,
                          "barycentric" => :int,
                          "pulsarcentric" => :int,
                          "az_start" => :float,
                          "za_start" => :float,
                          "src_raj" => :float,
                          "src_dej" => :float,
                          "tstart" => :float,
                          "tsamp" => :float,
                          "nbits" => :int,
                          "nsamples" => :int,
                          "fch1" => :float,
                          "foff" => :float,
                          "fchannel" => :float,
                          "nchans" => :int,
                          "nifs" => :int,
                          "refdm" => :float,
                          "flux" => :float,
                          "period" => :float,
                          "nbeams" => :int,
                          "ibeam" => :int,
                          "hdrlen" => :int,
                          "pb" => :float,
                          "ecc" => :float,
                          "asini" => :float,
                          "orig_hdrlen" => :int,
                          "new_hdrlen" => :int,
                          "sampsize" => :int,
                          "bandwidth" => :float,
                          "fbottom" => :float,
                          "ftop" => :float,
                          "obs_date" => String,
                          "obs_time" => String,
                          "accel" => :float,
                          # These are "non-standard" from C. Bochenek
                          "MJD_hour" => :int,
                          "MJD_minute" => :int,
                          "MJD_second" => :float,
                          "MJD_start" => :int,
                          "start_sample" => :int,
                          "end_sample" => :int)

const BIT_TYPE = Dict(1 => UInt8, 2 => UInt8, 4 => UInt8, 8 => UInt8, 16 => UInt16,
                      32 => UInt32)

function read_next_type(type, bytes, ptr)
    data, = reinterpret(type, @view bytes[ptr:(ptr + sizeof(type) - 1)])
    return data, ptr + sizeof(type)
end

function read_next_string(bytes, ptr)
    len, ptr = read_next_type(UInt32, bytes, ptr)
    return String(@view bytes[ptr:(ptr + len - 1)]), ptr + len
end

function read_next_header(bytes, ptr, float_type, int_type)
    header, ptr = read_next_string(bytes, ptr)
    if header == "HEADER_END"
        return "HEADER_END", nothing, ptr
    end
    typ = HEADER_TYPES[header]
    if typ == String
        value, ptr = read_next_string(bytes, ptr)
    else
        next_typ = typ == :float ? float_type : int_type
        value, ptr = read_next_type(next_typ, bytes, ptr)
    end
    return header, value, ptr
end

"""
    Filterbank(data,headers)

The datastructure that holds the the Filterbank file.

# Fields
-`data`: The data as a `DimArray` with dimensions `Samp` and `Freq`
-`headers`: The dictionary of header information
"""
struct Filterbank
    data::DimArray
    headers::Dict
end

"""
    Filterbank("file.fil")

Read a SIGPROC .fil file into a `Filterbank`.

# Arguments
- `filename::String`:  The name of the file

# Optional Arguments
- `accuracy::Symbol=:full`: Sets the accuracy level of `:full` or `:reduced`
- `start::Int`: The starting time sample to read from (inclusive)
- `stop::Int`: The stopping time sampel to read to (inclusive)
- `header_int::DataType`: The type of header integers, defaults to UInt32
- `header_float::DataType`: The type of header flots, defaults to Float64
"""
function Filterbank(filename::String; start=1, stop=nothing, header_int=UInt32,
                    header_float=Float64)
    f = mmap(filename)
    start_str, ptr = read_next_string(f, 1)
    @assert start_str == "HEADER_START"
    headers = Dict{String,HEADER_VALUE_TYPE}()
    while true
        header, value, ptr = read_next_header(f, ptr, header_float, header_int)
        if header == "HEADER_END"
            break
        else
            headers[header] = value
        end
    end
    # Grab remaining mmap'ed chunk
    data_bytes = @view f[ptr:end]
    # Pull out useful headers
    nchans = headers["nchans"]
    nbits = headers["nbits"]
    fch1 = headers["fch1"]
    foff = headers["foff"]
    # Read the remaining chunk
    bytes_per_sample = nchans * nbits ÷ 8
    nsamps = length(data_bytes) ÷ bytes_per_sample
    if isnothing(stop)
        stop = nsamps
    end
    # Preallocate data block
    samps = Samp(start:stop)
    freqs = Freq(range(; start=fch1, length=nchans, step=foff))
    data = DimArray(zeros(BIT_TYPE[nbits], length(samps), length(freqs)), (samps, freqs))
    for i in start:stop
        ptr += bytes_per_sample
        data[Samp(At(i))] = reinterpret(BIT_TYPE[nbits],
                                        @view f[ptr:(ptr + bytes_per_sample - 1)])
    end

    return Filterbank(data,headers)
end

export Filterbank, Samp, Freq

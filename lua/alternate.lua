local ext_to_alt_map = {
    h = { "c", "cpp", "cxx", "cc", "CC" },
    H = { "C", "CPP", "CXX", "CC" },
    hpp = { "cpp", "c" },
    HPP = { "CPP", "C" },
    c = { "h" },
    C = { "H" },
    cpp = { "h", "hpp" },
    CPP = { "H", "HPP" },
    cc = { "h" },
    CC = { "H", "h" },
    cxx = { "h" },
    CXX = { "H" },
}

local search_paths = {
    "../source",
    "../src",
    "../include",
    "../inc"
}

local M = { }

local function file_basename(path)
    for i=#path,1,-1
    do
        if path:byte(i) == 47
        then
            return path:sub(i+1, #path)
        end
    end

    return path
end

local function filename_extension(filename)
    for i=#filename,1,-1
    do
        if filename:byte(i) == 46
        then
            return filename:sub(i+1, #filename)
        end
    end

    return filename
end

local function filename_without_extension(filename)
    for i=#filename,1,-1
    do
        if filename:byte(i) == 46
        then
            return filename:sub(1, i-1)
        end
    end

    return filename
end

local function file_dirname(path)
    for i=#path,1,-1
    do
        if path:byte(i) == 47
        then
            return path:sub(1, i-1)
        end
    end

    return path
end

local function get_candidate_paths(curr_dir, filename, ext)
    local result = {}
    local filename_without_ext = filename_without_extension(filename)

    possible_exts = ext_to_alt_map[ext]
    if possible_exts then
        for _, alt_ext in ipairs(possible_exts) do
            table.insert(result, curr_dir .. "/" .. filename_without_ext .. "." .. alt_ext)

            for _, possible_path in ipairs(search_paths) do
                table.insert(result, curr_dir .. "/" .. possible_path .. "/" .. filename_without_ext .. "." .. alt_ext)
            end
        end
    end

    return result
end

local function find_alternate_file(path)
    local curr_dir = file_dirname(path)
    local filename = file_basename(path)
    local ext = filename_extension(filename)

    local candidate_paths = get_candidate_paths(curr_dir, filename, ext)

    local score = 0
    local result = nil
    for _, candidate_path in ipairs(candidate_paths) do
        local file_exists = vim.fn.filereadable(candidate_path)
        local buffer_exists = vim.fn.bufexists(candidate_path)
        local candidate_score = file_exists + buffer_exists
        if candidate_score > score then
            score = candidate_score
            result = candidate_path
        end
    end

    return result
end

function M.alternate()
    path = vim.api.nvim_buf_get_name(0)
    alternate = find_alternate_file(path)
    if alternate ~= nil
    then
        vim.cmd("e " .. alternate)
    end
end

return M

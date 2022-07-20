if exists("g:loaded_alternate") | finish | endif

command! Alternate lua require("alternate").alternate()

let g:loaded_alternate = 1

" function! ReloadAlpha()
" lua << EOF
"     for k in pairs(package.loaded) do 
"         if k:match("^share.nvim") then
"             package.loaded[k] = nil
"         end
"     end
" EOF
" endfunction
" nnoremap <Leader>pr :call ReloadAlpha()<CR>
" vnoremap <Leader>ps :lua require("share").share()<CR>

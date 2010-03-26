" html5validator.vim - html5 validate using Validator.nu API
"
" Author:  Kazuhito Hokamura <Kazuhito Hokamura>
" Version: 0.0.1
" License: MIT License <http://www.opensource.org/licenses/mit-license.php>

if exists('g:loaded_html5validator')
    "finish
endif
let g:loaded_html5validator = 1

let s:save_cpo = &cpo
set cpo&vim


function! s:error(str)
    echohl ErrorMsg
    echomsg a:str
    echohl None
endfunction

function! s:html5validate(filename)
    let filename = a:filename
    if filename == ''
        let filename = expand('%:p')
        if filename == ''
            call s:error('no such file')
            return
        endif
    else
        let filename = fnamemodify(filename, ':p')
        if !filereadable(filename)
            call s:error('no such file: ' . a:filename)
            return
        endif
    endif

    let url = 'http://html5.validator.nu/'
    let cmd = printf('curl -s --form out=json --form content=@%s %s',
    \                 filename, url)
    let res = system(cmd)
    if empty(res)
        call s:error('request faild')
        return
    endif
    let json = eval( substitute(res, '[\n\r]', '', 'g') )

    if empty(json.messages)
        echo 'Valid HTML5!!'
        cgetexpr ''
        cclose
        return
    endif

    let errors = []
    for row in json.messages
        let lastline = has_key(row, 'lastLine') ? row.lastLine : 1
        let type     = has_key(row, 'type')     ? row.type     : '-'
        let message  = has_key(row, 'message')
        \                ? substitute(row.message, '[“”]', '"', 'g') : '-'
        call add(errors, printf('%s:%s:[%s] %s',
        \                        filename, lastline, type, message))
    endfor
    setlocal errorformat=%f:%l:%m
    cgetexpr join(errors, "\n")
    copen
endfunction

command! -complete=file -nargs=? HTML5Vlidate call s:html5validate(<q-args>)


let &cpo = s:save_cpo

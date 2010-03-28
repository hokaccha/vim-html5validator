" html5validator.vim - html5 validate using Validator.nu API
"
" Author:  Kazuhito Hokamura <http://webtech-walker.com/>
" Version: 0.0.1
" License: MIT License <http://www.opensource.org/licenses/mit-license.php>

if exists('g:loaded_html5validator')
    finish
endif
let g:loaded_html5validator = 1

let s:save_cpo = &cpo
set cpo&vim


function! s:error(str)
    echohl ErrorMsg
    echomsg a:str
    echohl None
endfunction

function! s:html5validate()
    if !executable('curl')
        call s:error('"curl" not execute able')
        return
    endif

    let url = 'http://html5.validator.nu/'
    let filename = expand('%:p')
    let cmd = printf('curl -s --form out=json --form content=@%s %s',
    \                 filename, url)

    let json = system(cmd)
    if empty(json)
        call s:error('request faild')
        return
    endif

    let res_data = eval( substitute(json, '[\n\r]', '', 'g') )

    if empty(res_data.messages)
        echo 'Valid HTML5!!'
        cgetexpr ''
        cclose
        return
    endif

    let errors = []
    for row in res_data.messages
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

command! -complete=file -nargs=0 HTML5Vlidate call s:html5validate()


let &cpo = s:save_cpo

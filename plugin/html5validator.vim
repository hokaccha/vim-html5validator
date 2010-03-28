" html5validator.vim - html5 validate using Validator.nu API
"
" Author:  Kazuhito Hokamura <http://webtech-walker.com/>
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

function! s:html5validate()
    if !executable('curl')
        call s:error('"curl" not execute able')
        return
    endif

    let url = 'http://html5.validator.nu/'
    let timeout = 5
    let filename = expand('%:p')
    let quote = &shellxquote == '"' ?  "'" : '"'
    let cmd  = 'curl -s --connect-timeout ' . timeout . ' '
    let cmd .= '--form out=json --form content=@' .quote.filename.quote. ' '
    let cmd .= url

    let json = system(cmd)
    if empty(json)
        call s:error('request faild')
        return
    endif

    if has('win32')
        let json = iconv(json, 'utf-8', 'cp932')
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

command! -complete=file -nargs=0 HTML5Validate call s:html5validate()


let &cpo = s:save_cpo

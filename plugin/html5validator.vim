" html5validator.vim - description
"
" Author:  Kazuhito Hokamura <Kazuhito Hokamura>
" Version: 0.0.1
" License: MIT License <http://www.opensource.org/licenses/mit-license.php>

if exists('g:loaded_html5validator')
    finish
endif
let g:loaded_html5validator = 1

let s:save_cpo = &cpo
set cpo&vim

" plugin code here

let &cpo = s:save_cpo

scriptencoding utf-8

let s:PATTERN = '^$~.*[]\'
let s:Config = vital#fern#import('Config')
let s:AsyncLambda = vital#fern#import('Async.Lambda')

let s:STATUS_NONE = g:fern#STATUS_NONE
let s:STATUS_COLLAPSED = g:fern#STATUS_COLLAPSED

function! fern#renderer#nerdfont#new() abort
  let default = fern#renderer#default#new()
  return extend(copy(default), {
        \ 'render': funcref('s:render'),
        \ 'syntax': funcref('s:syntax'),
        \ 'highlight': funcref('s:highlight'),
        \})
endfunction

function! s:render(nodes) abort
  let options = {
        \ 'leading': g:fern#renderer#nerdfont#leading,
        \}
  let base = len(a:nodes[0].__key)
  let Profile = fern#profile#start('fern#renderer#nerdfont#s:render')
  return s:AsyncLambda.map(copy(a:nodes), { v, -> s:render_node(v, base, options) })
        \.finally({ -> Profile() })
endfunction

function! s:syntax() abort
  syntax match FernLeaf   /^\s*\zs.*[^/].*$/ transparent contains=FernLeafSymbol
  syntax match FernBranch /^\s*\zs.*\/.*$/   transparent contains=FernBranchSymbol
  syntax match FernRoot   /\%1l.*/     transparent contains=FernRootText

  syntax match FernLeafSymbol   /. / contained nextgroup=FernLeafText
  syntax match FernBranchSymbol /. / contained nextgroup=FernBranchText

  syntax match FernRootText   /.*\ze.*$/ contained nextgroup=FernBadgeSep
  syntax match FernLeafText   /.*\ze.*$/ contained nextgroup=FernBadgeSep
  syntax match FernBranchText /.*\ze.*$/ contained nextgroup=FernBadgeSep
  syntax match FernBadgeSep   //         contained conceal nextgroup=FernBadge
  syntax match FernBadge      /.*/         contained
  setlocal concealcursor=nvic conceallevel=2
endfunction

function! s:highlight() abort
  highlight default link FernRootText     Comment
  highlight default link FernLeafSymbol   Directory
  highlight default link FernLeafText     None
  highlight default link FernBranchSymbol Statement
  highlight default link FernBranchText   Statement
endfunction

function! s:render_node(node, base, options) abort
  let level = len(a:node.__key) - a:base
  if level is# 0
    let suffix = a:node.label =~# '/$' ? '' : '/'
    return a:node.label . suffix . '' . a:node.badge
  endif
  let leading = repeat(a:options.leading, level - 1)
  let symbol = s:get_node_symbol(a:node)
  let suffix = a:node.status ? '/' : ''
  return leading . symbol . a:node.label . suffix . '' . a:node.badge
endfunction

function! s:get_node_symbol(node) abort
  if a:node.status is# s:STATUS_NONE
    let symbol = s:find(a:node.bufname, 0)
  elseif a:node.status is# s:STATUS_COLLAPSED
    let symbol = s:find(a:node.bufname, 'close')
  else
    let symbol = s:find(a:node.bufname, 'open')
  endif
  return symbol
endfunction

" Check if nerdfont has installed or not
try
  call nerdfont#find('')
  function! s:find(bufname, isdir) abort
    return nerdfont#find(a:bufname, a:isdir) . g:fern#renderer#nerdfont#padding
  endfunction
catch /^Vim\%((\a\+)\)\=:E117:/
  function! s:find(bufname, isdir) abort
    return a:isdir is# 0 ? '|  ' : a:isdir ==# 'open' ? '|- ' : '|+ '
  endfunction
  call fern#logger#error(
        \ 'nerdfont.vim is not installed. fern-renderer-nerdfont.vim requires nerdfont.vim',
        \)
endtry

call s:Config.config(expand('<sfile>:p'), {
      \ 'leading': ' ',
      \ 'padding': ' ',
      \})

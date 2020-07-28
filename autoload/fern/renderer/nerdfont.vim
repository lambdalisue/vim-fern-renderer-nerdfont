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
        \})
endfunction

function! s:render(nodes, marks) abort
  let options = {
        \ 'leading': g:fern#renderer#nerdfont#leading,
        \ 'marked_symbol': g:fern#renderer#nerdfont#marked_symbol,
        \ 'unmarked_symbol': g:fern#renderer#nerdfont#unmarked_symbol,
        \}
  let base = len(a:nodes[0].__key)
  let Profile = fern#profile#start('fern#renderer#nerdfont#s:render')
  return s:AsyncLambda.map(copy(a:nodes), { v, -> s:render_node(v, a:marks, base, options) })
        \.finally({ -> Profile() })
endfunction

function! s:syntax() abort
  syntax match FernLeaf  /^\s*[^\x00-\x7F]/ nextgroup=FernBranch
  syntax match FernBranch /\s*.*\/$/ contained
  syntax match FernRoot   /\%1l.*/
  execute printf(
        \ 'syntax match FernMarked /^%s.*/',
        \ escape(g:fern#renderer#nerdfont#marked_symbol, s:PATTERN),
        \)
endfunction

function! s:render_node(node, marks, base, options) abort
  let prefix = index(a:marks, a:node.__key) is# -1
        \ ? a:options.unmarked_symbol
        \ : a:options.marked_symbol
  let level = len(a:node.__key) - a:base
  if level is# 0
    let suffix = a:node.label =~# '/$' ? '' : '/'
    return prefix . a:node.label . suffix
  endif
  let leading = repeat(a:options.leading, level - 1)
  let symbol = s:get_node_symbol(a:node)
  let suffix = a:node.status ? '/' : ''
  return prefix . leading . symbol . a:node.label . suffix
endfunction

function! s:get_node_symbol(node) abort
  if a:node.status is# s:STATUS_NONE
    let symbol = nerdfont#find(a:node.bufname, 0)
  elseif a:node.status is# s:STATUS_COLLAPSED
    let symbol = nerdfont#find(a:node.bufname, 1)
  else
    let symbol = nerdfont#directory#find('open')
  endif
  return symbol . '  '
endfunction

call s:Config.config(expand('<sfile>:p'), {
      \ 'leading': ' ',
      \ 'marked_symbol': '✓  ',
      \ 'unmarked_symbol': '   ',
      \})

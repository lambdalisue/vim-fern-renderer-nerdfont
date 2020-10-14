scriptencoding utf-8

let s:PATTERN = '^$~.*[]\'
let s:Config = vital#fern#import('Config')
let s:AsyncLambda = vital#fern#import('Async.Lambda')
let s:STATUS_NONE = g:fern#STATUS_NONE
let s:STATUS_COLLAPSED = g:fern#STATUS_COLLAPSED

let g:fern#renderer#nerdfont#root_symbol = get(g:, 'fern#renderer#nerdfont#root_symbol', "")

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
  let len = len(a:nodes)

  let level_dict = {}
  for i in range(len - 1, 0, -1)
    let node = a:nodes[i]
    if i + 1 < len 
      let node.next_level = a:nodes[i + 1].level
    else
      let node.next_level = 0
    endif

    let node.level = len(node.__key) - base

    if get(level_dict, node.level, 0) != 1
      let node.last = 1
    else
      let node.last = 0
    endif

    for key in keys(level_dict)
      if key > node.level
        let level_dict[key] = 0
      endif
    endfor
    let level_dict[node.level] = 1
  endfor

  for i in range(len)
    let node = a:nodes[i]

    " 0:│  1:└ 
    let last_intent_lines = i == 0 ? [0] : a:nodes[i - 1].intent_lines
    let node.intent_lines = [repeat([0], node.level)][0]
    let len_last = len(last_intent_lines)
    let len_cur = len(node.intent_lines)

    let last_intent_len = min([len_last, len_cur])
    for k in range(last_intent_len)
      let node.intent_lines[k] = last_intent_lines[k]
    endfor

    if node.last == 1 && i != 0
      let node.intent_lines[len_cur - 1] = 1
    endif

  endfor

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
    return g:fern#renderer#nerdfont#root_symbol . a:node.label . suffix . '' . a:node.badge
  endif

  let leading = ""

  let intent_len = len(a:node.intent_lines)
  for i in range(intent_len)
    let intent = a:node.intent_lines[i]
    if intent == 0
      let leading = leading . "│ "
    elseif intent == 1 && i == intent_len - 1
      let leading = leading . "└ "
    else
      let leading = leading . "  "
    endif
  endfor

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

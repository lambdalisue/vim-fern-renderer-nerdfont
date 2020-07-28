if exists('g:fern_renderer_nerdfont_loaded')
  finish
endif
let g:fern_renderer_nerdfont_loaded = 1

call extend(g:fern#renderers, {
      \ 'nerdfont': function('fern#renderer#nerdfont#new'),
      \})

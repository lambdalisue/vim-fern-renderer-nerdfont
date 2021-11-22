# 🌿 fern-renderer-nerdfont.vim

[![fern renderer](https://img.shields.io/badge/🌿%20fern-plugin-yellowgreen)](https://github.com/lambdalisue/fern.vim)

![image](https://user-images.githubusercontent.com/17700877/142896060-6d7bae71-d97a-45b4-81e2-26c52b1cc4bd.png)

[fern.vim](https://github.com/lambdalisue/fern.vim) plugin which add file type icons through [lambdalisue/nerdfont.vim](https://github.com/lambdalisue/nerdfont.vim).

## Requreiments

- [lambdalisue/nerdfont.vim](https://github.com/lambdalisue/nerdfont.vim)
- [Nerd Fonts](https://www.nerdfonts.com/)

## Usage

Set `"nerdfont"` to `g:fern#renderer` like:

```vim
let g:fern#renderer = "nerdfont"
```

Set `1` to `g:fern#renderer#nerdfont#indent_line` to enable indent line:

```vim
let g:fern#renderer#nerdfont#indent_line = 1
```
<img width="350" src="https://user-images.githubusercontent.com/17700877/142837116-ef909d28-d3b7-4fbb-9459-ae1fb54670cd.png"/>


Set `g:fern#renderer#nerdfont#root_symbol` to modiy root symbol:
```vim
let g:fern#renderer#nerdfont#root_symbol = "≡ "
```

## See also

- [lambdalisue/glyph-palette.vim](https://github.com/lambdalisue/glyph-palette.vim) - Apply individual colors on icons
- [lambdalisue/fern-renderer-devicons.vim](https://github.com/lambdalisue/fern-renderer-devicons.vim) - Use devicons instead

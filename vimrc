" scriptencoding utf-8
set encoding=utf-8

syntax on
set spell spelllang=en_us
hi clear SpellBad
hi SpellBad cterm=underline
set showbreak=↪\ 
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set list
set numberwidth=3
set number

map <Up> <Nop>
map <Down> <Nop>
map <Left> <Nop>
map <Right> <Nop>
imap <Up> <Nop>
imap <Down> <Nop>
imap <Left> <Nop>
imap <Right> <Nop>

nnoremap <Space> i_<Esc>r " Map space (in command mode) to inserting a single character

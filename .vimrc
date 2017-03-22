execute pathogen#infect()
Helptags                    " be sure that help tags for plugins are generated.

" As per: http://vim.wikia.com/wiki/Set_working_directory_to_the_current_file
"  The following are ways to automatically ensure the
"  cwd is the one the file is in.
if exists('+autochdir')
  set autochdir
else
  autocmd BufEnter * silent! lcd %:p:h
endif
"
autocmd BufEnter * :syntax sync fromstart
"
" If uncommmented, allows you to specify that you want to be in the directory
" in which the file exists by typing ",cd" in command-mode
"  (do not type :,cd as that is different!)
" nnoremap ,cd :cd %:p:h<CR>:pwd<CR>
"
" An alternative method of accomplishing easy edits of files in a directory is
" to have the following in the vimrc
"    cabbr <expr> %% expand('%:p:h')
" then, you would type something like
"   :e %%
" (which would get replaced with the
" path of the file currently being edited.

" New-way (since vim 7.3) to highlight a column.
if exists('+colorcolumn')
  highlight ColorColumn ctermbg=234 ctermfg=white guibg=#592929
  set colorcolumn=81,101
endif

" Old-school way to highlight in red anything > col 80.
highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
" More recent suggestion on accomplishing this is:
au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
" The following line exists so we can see the effect of the over-80 highlight.
"##########################################################################->80|##############->100|

" Tell vim that the terminal supports 256 colors.
set t_Co=256

" If your sshd has "AcceptEnv COLORFGBG" then you may not need to set the
" bg color explicitly.
" Instead, setup your ~/.ssh/config to include:
"   Host *
"     SendEnv COLORFGBG

" My terminal is white-on-black, and so the background is 'dark'
" This tells vim to use colors that show up better on a dark background.
set bg=dark

" set the background color for line numbers column
highlight LineNr ctermfg=yellow ctermbg=237

" Sets various editor niceties
set notimeout                  " Avoid 'sticky esc'
set ttimeout                   " .. by setting
set ttimeoutlen=100            " .... these three...
set scrolloff=5                " Keep 5 lines visible above/below cursor
set scrolljump=1               " move by one line at a time.
set noerrorbells
set undolevels=1000
set showmatch                  " highlight matching paren, curly, etc.
set showcmd                    " shows what is selected
set showmode                   " shows the mode the editor is in (e.g. INSERT)
set hlsearch                   "
set mousehide                  " hide the mouse when typing text
set listchars=tab:\|-,trail:=,extends:$  " setup display of trailing ws
set list                       " show the listchars
set winminheight=0             " (aka wmh) smallest win only shows its name
set number                     " show linenumbers
set tabstop=2                  " (aka ts) tabstops are 2 chrs
set shiftwidth=2               " (aka sw) shiftwidth is 2 chrs
set expandtab                  " convert ^T to spaces
set smartindent                " indent intelligently
set nowrap                     " do NOT wrap lines by default.
set laststatus=2               " Show the status bar even when just 1 window open
" Tell vim to show a list of all files when selecting one via tab completion.
set wim=longest:full,list:full
" Setup netrw (the default vim file browser) to be more useful/useable
let g:netrw_banner = 0         " remove the banner
let g:netrw_liststyle = 3      " display with tree-view

" Allow the use of the mouse in terminals too
" Note that this will prevent copying/selecting in the terminal unless:
"   If you're on PC, hold <shift> while selecting
"   If you're on Mac, hold <alt> while selecting
" This will allow copying from the terminal window while in vim with mouse=a.
set mouse=a
" Turn on syntax highlighting by default.
syn on

" Setup for folding follows.
set foldmethod=syntax          " Fold based on the language syntax.
" The below sets up folding based on hitting <space> while in cmd mode.
nnoremap <silent> <space> @=(foldlevel('.')?'za':"\<space>")<CR>
vnoremap <Space> zf
" Below causes all folds to be open by default when opening a file
au BufRead * normal zR

" Returns to the last edit position when opening files.
autocmd BufReadPost *
 \ if line("'\"") > 0 && line("'\"") <= line("$") |
 \   exe "normal! g`\"" |
 \ endif

" Keep undo history across sessions, by storing in file.
set undofile
"##############################################################################

" iTerm and iTerm2 send a terminal reset when you hit <cmd-r>
" This messes up arrow keys in vim. There are a number of ways of fixing it:
"   http://superuser.com/questions/215180/when-running-screen-on-osx-commandr-messes-up-arrow-keys-in-vim-across-all-scr
" The two easiest are:
" 1) map the key combination <cmd-r> to 'ignore' from preferences in iTerm
"    (described below next section of mappings)
" 2) include the following mappings.
" Needed for tmux and vim to play nice after a <cmd-r> from iTerm2
map <Esc>[A <Up>
map <Esc>[B <Down>
map <Esc>[C <Right>
map <Esc>[D <Left>
" Console movement
cmap <Esc>[A <Up>
cmap <Esc>[B <Down>
cmap <Esc>[C <Right>
cmap <Esc>[D <Left>
" Note that another way to fix this (which is what I do) is to setup iTerm
" to NOT send term-reset by overriding the mapping.
" Open iTerm2.
" select iTerm2 -> Preferences
"  -> click 'Keys' tab
"  -> click the '+' icon below the Key Mappings pane (left of '-')
"  -> In 'Keyboard Shortcut' field, type <CMD>-r
"  -> In 'Action' field, confirm (or select) 'ignore'
"  -> Click 'OK'
"  You should see cmd-r map to ignore in the 'Key Mappings' pane.

" Move by displayed lines instead of 'real' lines:
noremap k gk
noremap j gj
" And remap what used to be move by displayed lines to move to 'real' lines.
noremap gk k
noremap gj j

"##############################################################################
"####### BELOW HERE ARE PLUGIN AND SIMILAR INITIALIAZTIONS ####################
"##############################################################################
" Plugins and other conditionally-enabled things:
" incsearch:      [ shows results while entering the search pattern ]
" lightline.vim:  [ makes status bar pretty ]
" tagbar:         [ displays tree of tags (code) when tags exist ]
"           to use: type \tag
" supertab:       [ enhance tab use, e.g. tab between search results ]
" vim-fugitive    [ provide hooks for dealing with git ]
" vim-mercenary   [ provide hooks for dealing with mercurial ]
" vim-indent-guides: [ colorizes leading whitespace to show indent level ]
"           To toggle use, type <leader>ig
"             (by default <leader> is backslash, so '\ig' toggles it on/off)
" vim-signify:    [ shows lines which have been changed in git, hg, etc. ]
"             removed for now while debugging vim-mercenary.
" look at:
"             https://github.com/scrooloose/syntastic

"###### clang-format ##### NOT A PLUGIN ## NOT A PLUGIN ## NOT A PLUGIN #######
" Setup clang-format
if !empty(glob("/usr/local/share/clang/clang-format.py"))
  map <C-K> :pyf /usr/local/share/clang/clang-format.py<CR>
  imap <C-K> <ESC>:pyf /usr/local/share/clang/clang-format.py<CR>i
endif
"##############################################################################

"###### incsearch.vim #########################################################
"   https://github.com/haya14busa/incsearch.vim
if !empty(glob("~/.vim/bundle/incsearch.vim"))
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)
endif
"##############################################################################

"###### lightline #############################################################
"   https://github.com/itchyny/lightline.vim
""
if !empty(glob("~/.vim/bundle/lightline.vim"))
  set noshowmode  " don't need the modeline when lightline is already showing it.
endif
"##############################################################################

"###### tagbar ################################################################
"   https://github.com/majutsushi/tagbar
" if !empty(glob("~/.vim/bundle/tagbar"))
" endif
"##############################################################################

"##############################################################################
"   https://github.com/rhysd/vim-clang-format
" MacOsX doesn't install clang-format by default.
" You can get it with homebrew:
"   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
"   brew install clang-format
" if !empty(glob("~/.vim/bundle/vim-clang-format"))
" endif
"##############################################################################

"###### vim-fugitive ###########################################################
"   https://github.com/tpope/vim-fugitive
if !empty(glob("~/.vim/bundle/vim-fugitive"))
  set diffopt+=vertical
endif
"##############################################################################

"###### vim-indent-guides #####################################################
"   https://github.com/nathanaelkane/vim-indent-guides
if !empty(glob("~/.vim/bundle/vim-indent-guides"))
  let g:indent_guides_auto_colors = 0
  let g:indent_guides_guide_size = 1
  hi IndentGuidesOdd  ctermbg=234
endif
"##############################################################################

"###### vim-mercenary #########################################################
"   https://github.com/jlfwong/vim-mercenary
" if !empty(glob("~/.vim/bundle/vim-mercenary"))
" endif
"##############################################################################

"##############################################################################
"###### CHEAT SHEETS FOLLOW. You can safely ignore/remove this... #############
"##############################################################################
"###### tmux cheat sheet ######################################################
" From within tmux:
"   C-b           : enter cmd mode
"   C-b %         : split left/right
"   C-b <arrow>   : navigate windows
"   C-b p         : navigate to prev window
"   C-b n         : navigate to next window
"   C-b c         : create new window
"   C-b d         : detatch session from term
"   C-b z         : toggle fullscreen
"   C-b C-<arrow> : resize in arrow direction
"   C-v ,         : rename window
"   C-b C-#       : show buffers
" Assuming vi key bindings (in .tmux.conf: set-window-option -g mode-keys vi)
" To copy/scroll in a tmux window:
"   C-b <PageUp>  : enters copy/scroll mode.
"         : -or-
"   C-b [         : After which you're in copy/scroll mode.
"     100 <arrow> (move 100 in <arrow> direction)
"     <shift>-g   : scroll to bottom
"     C-<up>      : scroll page-up
"     C-<down>    : scroll page-down
"     C-u         : scroll half-page-up
"     C-d         : scroll half-page-down
"     C-<space>   : start selection of copy region (now in copy mode)
"       <enter>   : do copy of the selected region
"     C-c         : exit mode.
"     /           : search forward
"     ?           : search backward
"     n           : search again in same direction
"     N           : search again in opposite direction
"
" To see detached tmux sessions:
"   tmux ls
" To attach to previously detached
"   tmux -attach -t 0  # where '0' is the name of the session you want
" To name a tmux session:
"   tmux rename-session -t old-session-name new-session-name
" To create a tmux session with a name:
"   tmux new -s new-session-name
" To see copied buffers:
"   tmux list-buffers
" To print out buffer contents
"   tmux show-buffer -b buffer-name
" To save buffer contents to file
"   tmux save-buffer -b buffer-name file-name
"##############################################################################
" ##### www workflow cheat sheet #############################################
" Mercurial Workflow:
" hg outgoing -p  " Look at the things that you'll be landing.
" hg show         " perhaps the same?
"
" www/  dev lifecycle:
"
" arc feature bookmarkname          " create new bookmark/branch
" vim stuff                         " edit pre-existing stuff
" hg add new_stuff                  " add new stuff
" arc rebuild blahblahblah          " rebuilds the world
" hg commit                         " commit to local bookmark
" arc diff                          " publish to phabricator
"                       " .... time passes
" hg checkout bookmarkname          " switch back to local bookmark
"                       " .... editing/etc. happens
" arc rebuild xcontroller           " rebuild the world again...
" hg amend                          " amend the local diff
" arc diff                          " publish new changes to phabricator
"                       " .... time passes/diff accepted!
" arc land                          " diff is landed in head
"
" arc feature --cleanup "cleanup bookmark
"##############################################################################

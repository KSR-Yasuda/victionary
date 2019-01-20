" =========================================================================
" Vim plugin for looking up words in an online dictionary (ie. WordNet)
" A fork of the vim-online-thesaurus plugin
" Author:	Jose Francisco Taas
" Version: 1.0.0
" Credits to both Anton Beloglazov and Nick Coleman: original idea and code
" And to Dave Pearson: RFC 2229 client for ruby
" NOTE: This is a very hackish implementation since I didn't originally
" plan on sharing the code. It could also be because I'm a piss-poor coder.
" =========================================================================
if exists("g:victionary#loaded")
	finish
endif

let s:path = expand('<sfile>:p:h')
let s:dictpath = s:path . '/dict.rb'

function! s:Lookup(word)
	silent keepalt belowright split victionary
	setlocal noswapfile nobuflisted nospell nowrap modifiable
	setlocal buftype=nofile bufhidden=hide
	1,$d
	echo "Fetching " . a:word . " from the WordNet dictionary..."
	exec "silent 0r !" . s:dictpath . " -d wn " . a:word
	normal! ggiWord: 
ruby << EOF
	@buffer = VIM::Buffer.current
	resizeTo = VIM::evaluate("line('$')") + 1
	for i in 1..@buffer.count
		if @buffer[i].include? "2:"
			resizeTo = i
			break
		end
	end
	VIM.command("resize #{resizeTo - 1}")
EOF
	nnoremap <silent> <buffer> q :q<CR>
	setlocal nomodifiable filetype=victionary
endfunction

function! s:WordPrompt()
	call inputsave()
	let word = input('Enter word: ')
	call inputrestore()
	if word == ""
		return
	end
	redraw
	call s:Lookup(word)
endfunction

if !exists('g:victionary#map_defaults')
	let g:victionary#map_defaults = 1
endif

nnoremap <Plug>(victionary#word_prompt) :call <SID>WordPrompt()<Return>
nnoremap <Plug>(victionary#under_cursor) :call <SID>Lookup('<C-r><C-w>')<Return>

if g:victionary#map_defaults
	nnoremap <unique> <Leader>d <Plug>(victionary#word_prompt)
	nnoremap <unique> <Leader>D <Plug>(victionary#under_cursor)
endif

command! -nargs=1 Victionary :call <SID>Lookup(<f-args>)

let g:victionary#loaded = 1

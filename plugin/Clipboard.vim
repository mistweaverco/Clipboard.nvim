if exists("g:loaded_Clipboard")
        finish
endif
let g:loaded_Clipboard = 1

let s:PluginName = "Clipboard.nvim"
let s:isVerbose = 0

function! s:FileExists(filepath)
        if filereadable(a:filepath)
                return 1
        else
                return 0
        endif
endfunction

function! s:ReadfileAsString(filepath)
        return readfile(a:filepath)
endfunction

function! s:GetCurrentFile()
        return expand("%")
endfunction

function! s:OnJobEventHandler(job_id, data, event) dict
        if a:event == 'stdout'
                let str = self.shell.' stdout: '.join(a:data)
        elseif a:event == 'stderr'
                let str = self.shell.' stderr: '.join(a:data)
        else
                let str = self.shell.' finished'
        endif
        echom str
endfunction

let s:jobEventCallbacks = {
        \ 'on_stdout': function('s:OnJobEventHandler'),
        \ 'on_stderr': function('s:OnJobEventHandler'),
        \ 'on_exit': function('s:OnJobEventHandler')
\ }

function! s:ExecExternalCommand(command)
        if has("nvim") == 1
                if s:isVerbose == 0
                        call jobstart(["bash", "-c", a:command])
                else
                        let winnr = winnr()
                        botright new | call termopen(["bash", "-c", a:command], extend({"shell": s:PluginName}, s:jobEventCallbacks))
                endif
        elseif v:version >= 800
                if s:isVerbose == 0
                        call job_start("bash -c " . a:command)
                else
                        new termopen(["bash", "-c", a:command], extend({"shell": s:PluginName}, s:jobEventCallbacks))
                endif
        else
                if s:isVerbose == 1
                        execute "!" . a:command
                else
                        silent execute "!" . a:command
                endif
        endif
endfunction

function! Clipboard#Verbose(enable)
        if a:enable == 1
                let s:isVerbose = 1
        else
                let s:isVerbose = 0
        endif
endfunction

function! Clipboard#FromFile()
        let cmd =  "xclip -sel clip < " . s:GetCurrentFile()
        call s:ExecExternalCommand(cmd)
endfunction

function! Clipboard#FromBuffer()
        execute ":%y\"*"
endfunction

command! Clipboard call Clipboard#FromBuffer()


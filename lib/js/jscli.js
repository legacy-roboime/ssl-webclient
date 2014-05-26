;(function () {

//var history = []
//var position = -1
var history = ['']
var position = 0

// keycodes: http://www.cambiaresearch.com/articles/15/javascript-char-codes-key-codes
var TABKEY = 9
var ENTERKEY = 13
var UPKEY = 38
var DOWNKEY = 40


// print string to the output
function print(str) {
    document.getElementById('output').innerHTML+= str + '\n'
    // autoscroll output area
    output.scrollTop = output.scrollHeight - output.clientHeight
}
// clear the output
function clear() {
    document.getElementById('output').innerHTML = ''
}
// this will init jscli
function init() {
    function focusInput() {
        document.getElementById('input').focus()
    }
    // when clicking output focus should go to the input
    document.getElementById('output').addEventListener('focus', focusInput, false)
    document.getElementById('wrap').addEventListener('click', focusInput, false)

    // we should capture tab, enter and maybe some other keys
    document.getElementById('input').addEventListener('keydown', function (e) {

        switch(e.keyCode) {
        case TABKEY:
            //TODO: autocomplete
            this.value += "\t"//demo
            // prevent losing focus
            e.preventDefault()
            break
        case ENTERKEY:
            var expression = this.value
            this.value = ''
            //TODO: parse and execute
            jscli.eval(expression)
            // prevent inputing \n
            history[history.length - 1] = expression
            history.push('')
            position = history.length - 1
            e.preventDefault()
            break
        case UPKEY:
            if (position == history.length - 1)
                history[position] = this.value
            if (position > 0)
                this.value = history[--position]
            else if (position == 0)
                this.value = history[position]
            e.preventDefault()
            break
        case DOWNKEY:
            if (position < history.length - 1)
                this.value = history[++position]
            e.preventDefault()
            break
        }
    }, false)
}

// we should init when window loads
window.addEventListener('load', init)

window.jscli = {
    VERSION: '0.0.2',
    print: print,
    clear: clear,
    eval: function(_) {return _},
}

})()


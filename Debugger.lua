local debugger = {
    enabled = false,
    prefix = "[DEBUG START]{ ",
    postfix = " }[DEBUG END]"
}

function debugger:console(variableToPrint)
    if debugger.enabled then
        print(debugger.prefix .. tostring(variableToPrint) .. debugger.postfix)
    end
end

return debugger
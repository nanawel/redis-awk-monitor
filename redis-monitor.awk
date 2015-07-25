#!/usr/bin/gawk -f
# Anael Ollier 2015-07-25
# nanawel {at} nospam gmail {dot} com
#
# Usage:
#     redis-cli monitor | gawk -f redis-monitor.awk

function max(a, b) {
    return a >= b ? a : b
}

function min(a, b) {
    return a <= b ? a : b
}

BEGIN {
    print ":: redis-monitor :: Running..."
    FS = " "
    outputHeight = 0
    totalOperations = 0
    startTime = 0
    eraseEachLoop = 1
    marginLines = 5

    PROCINFO["sorted_in"] = "@val_num_desc"
};

{
    # Increment current operation count
    op = gensub(/"([a-zA-Z]+)"/, "\\1", 1, $4)
    if (op == "") {
        next
    }
    operations[op]++

    # Init timer on first processed line
    if (startTime == 0) {
        startTime = systime()
    }

    # Increment current operation/key count
    key = gensub(/"([^"]+)"/, "\\1", 1, $5)
    if (key != "") {
        opKeys[op " / " key]++
    }
    totalOperations++

    # Erase previous output
    lastOutputHeight = outputHeight
    if (eraseEachLoop) {
        for (i = 0; i < lastOutputHeight; i++) {
            printf "\033[1A\033[K\r"      # Move up one line and erase it
        }
    }

    # Calculate max displayable lines using terminal height
    if (totalOperations % 10 == 0) {
        cmd = "tput lines"
        cmd | getline maxLines
        close(cmd)
        #print "maxLines= " maxLines
        #outputHeight++
        maxLines -= marginLines
    }

    # Print current operations count
    outputHeight = 0
    for (oIdx in operations) {
        printf "[%- 10s] %d\n", oIdx, operations[oIdx]
        outputHeight++
    }
    
    elapsedTime = systime() - startTime
    if (elapsedTime != 0) {
        printf "[Avg Op/sec] %.2f\n", totalOperations / elapsedTime
        outputHeight++
    }

    if (length(opKeys)) {
        # Find longuest key
        keyLength = 0
        for (okIdx in opKeys) {
            keyLength = max(keyLength, length(okIdx))
        }

        printf "\n"
        outputHeight++

        print ":: Keys/Operations ::"
        outputHeight++
        for (okIdx in opKeys) {
            if (outputHeight >= maxLines) {
                print "[... Truncated results ...] "
                outputHeight++
                break
            }

            printf "[%-" keyLength "s] %d\n", okIdx, opKeys[okIdx]
            outputHeight++
        }
    }

    # Avoid flickering
    system("sleep 0.1");
};

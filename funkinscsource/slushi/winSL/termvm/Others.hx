package slushi.winSL.termvm;

/**
 * Author: Trock
 */

class Others {
    public static function tokenize(commandLine:String):Array<String> {
        var tokens:Array<String> = [];
        var currentToken:StringBuf = new StringBuf();
        var inQuotes:Bool = false;
        var i:Int = 0;

        while (i < commandLine.length) {
            var c:String = commandLine.charAt(i);
            switch c {
                case '"':
                    inQuotes = !inQuotes;
                case ' ':
                    if (inQuotes) {
                        currentToken.add(c);
                    } else if (currentToken.length > 0) {
                        tokens.push(currentToken.toString());
                        currentToken = new StringBuf();
                    }
                case '\\':
                    if (i + 1 < commandLine.length) {
                        var nextChar = commandLine.charAt(i + 1);
                        if (nextChar == '"' || nextChar == '\\') {
                            currentToken.add(nextChar);
                            i++;
                        }
                    }
                default:
                    currentToken.add(c);
            }
            i++;
        }

        if (currentToken.length > 0) {
            tokens.push(currentToken.toString());
        }

        return tokens;
    }

    public static function extract(tokens:Array<String>):Array<Dynamic> {
        var commands:Array<Dynamic> = [];
        var command:Array<String> = [];

        for (token in tokens) {
            command.push(token);
        }
        if (command.length > 0) {
            commands.push({command: command});
        }
        return commands;
    }

    public static function process(commands:Array<Dynamic>):Array<Dynamic> {
        var processedCommands:Array<Dynamic> = [];
        for (command in commands) {
            // New command entry with a placeholder for a potential operator
            processedCommands.push({ command: command.command });
        }
        return processedCommands;
    }
}
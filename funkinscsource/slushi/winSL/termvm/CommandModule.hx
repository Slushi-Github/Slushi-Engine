package slushi.winSL.termvm;

/**
 * Author: Trock
 */

class CommandModule {
    public var commandRoots:Array<String>;
    public var executeFunc:Terminal->String->Array<String>->Dynamic->Void;

    public function new(commandRoots:Array<String>, executeFunc:Terminal->String->Array<String>->Dynamic->Void) {
        this.commandRoots = commandRoots;
        this.executeFunc = executeFunc;
    }

    public function execute(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void {
        this.executeFunc(terminal, command, args, metadata);
    }

    public function getCommandRoots():Array<String> {
        return this.commandRoots;
    }
}
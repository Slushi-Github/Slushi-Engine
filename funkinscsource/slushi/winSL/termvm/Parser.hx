package slushi.winSL.termvm;

/**
 * Author: Trock
 */

class Parser {
    public var modules:Map<ModuleType, Module>;

    public function new(modules:Array<Module>) {
        this.modules = new Map<ModuleType, Module>();
        for (module in modules) {
            this.modules.set(module.moduleType, module);
        }
    }

    public function parse(commandLine:String):Array<Dynamic> {
        var tokens = this.modules.get(ModuleType.TOKENIZER).execute([commandLine]);
        var commands = this.modules.get(ModuleType.EXTRACTOR).execute([tokens]);
        return this.modules.get(ModuleType.OPERATOR_HANDLER).execute([commands]);
    }
}
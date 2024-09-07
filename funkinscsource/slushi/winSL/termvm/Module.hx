package slushi.winSL.termvm;

/**
 * Author: Trock
 */


typedef Implementation = Dynamic->Dynamic;

class Module {
    public var moduleType:ModuleType;
    public var implementation:Implementation;

    public function new(moduleType:ModuleType, implementation:Implementation) {
        this.moduleType = moduleType;
        this.implementation = implementation;
    }

    public function execute(args:Array<Dynamic>):Dynamic {
        return Reflect.callMethod(this, implementation, args);
    }
}

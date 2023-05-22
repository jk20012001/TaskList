import { ShaderNode } from "../../../base";
import { ConcretePrecisionType } from "../../../type";

export default class @NodeName@ extends ShaderNode {
    concretePrecisionType = ConcretePrecisionType.Fixed;

    generateCode () {
@generateCode@
    }
	
	/*
	getValidInputType () : boolean {
@isValidInputType@
	}
	getInputName () : boolean {
@getInputName@
	}
	*/
}

/*
ShaderNode::AutoConvertInputType --- 单通道支持自动转多通道, 否则报错
*/
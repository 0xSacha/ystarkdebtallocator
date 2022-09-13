%builtins output range_check bitwise 

from starkware.cairo.common.math import unsigned_div_rem, assert_le_felt
from starkware.cairo.common.serialize import serialize_word, serialize_array
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_label_location
// from keccak import keccak_felts, finalize_keccak
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.keccak import keccak_felts


func calcul_score1{ range_check_ptr }(
        input_strat1_len: felt,
        input_strat1: felt*,
        debt_ratio1: felt
    ) -> (
       score1: felt
    ){
    // calculate apy 10^3 precision
    //.....
    let start1_apy_ = 25000;

    // eventual condition on the debt_ratio if risky strategy or with lock 
    assert_le_felt(debt_ratio1, 2000);

    // return score
    let score1_ = start1_apy_ * debt_ratio1;
    return(score1= score1_);
    }


func calcul_score2{ range_check_ptr }(
        input_strat2_len: felt,
        input_strat2: felt*,
        debt_ratio2: felt
    ) -> (
       score2: felt
    ){
    // calculate apy 10^3 precision
    //.....
    let start2_apy_ = 11000;

    // eventual condition on the debt_ratio if risky strategy or with lock 
    assert_le_felt(debt_ratio2, 8000);

    // return score
    let score2_ = start2_apy_ * debt_ratio2;
    return(score2= score2_);
    }


func calcul_score3{ range_check_ptr }(
        input_strat3_len: felt,
        input_strat3: felt*,
        debt_ratio3: felt
    ) -> (
       score3: felt
    ){

     let start3_apy_ = 54000;

    // eventual condition on the debt_ratio if risky strategy or with lock 

    // return score
    let score3_ = start3_apy_ * debt_ratio3;
    return(score3= score3_);
    }


func serialize_word_from_pointer{output_ptr: felt*}(word) {
    assert [output_ptr] = [word];
    let output_ptr = output_ptr + 1;
    return ();
}


func main{output_ptr: felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}() {
    alloc_locals;
    // let (local strategies : felt*) = alloc();
    let (local debt_ratio : felt*) = alloc();
    let (local strat1 : felt*) = alloc();
    let (local strat2 : felt*) = alloc();
    let (local strat3 : felt*) = alloc();

    // let (keccak_ptr : felt*) = alloc();
    // local keccak_ptr_start : felt* = keccak_ptr;


        // assert len(program_input['strategies']) == 3
        // assert program_input['strategies'][0] == 0x04776e1e8Cc73FAAf61e4243Cc3f3A4f5458D6B5
        // assert program_input['strategies'][1] == 0x0262e8331dfA2d2BeCF26395270BCe6a9Ac5A197
        // assert program_input['strategies'][2] == 0x8D2fE2D23c97f33A665f6730fa07D25D37FF8355
        // strategies = ids.strategies
        // for i, val in enumerate(program_input['strategies']):
        //      memory[strategies + i] = val

    %{  
        assert len(program_input['debt_ratio']) == 3
        sum_debt_ratio = 0 
        for i, val in enumerate(program_input['debt_ratio']):
            sum_debt_ratio = sum_debt_ratio + val
        assert sum_debt_ratio == 10000

        
        assert len(program_input['strategy1_input']) == 3
        assert len(program_input['strategy2_input']) == 2
        assert len(program_input['strategy3_input']) == 4
            
        debt_ratio = ids.debt_ratio
        for i, val in enumerate(program_input['debt_ratio']):
             memory[debt_ratio + i] = val


        strat1ref = ids.strat1
        for i, val in enumerate(program_input['strategy1_input']):
            memory[strat1ref + i] = val

        strat2ref = ids.strat2
        for i, val in enumerate(program_input['strategy2_input']):
            memory[strat2ref + i] = val

        strat3ref = ids.strat3
        for i, val in enumerate(program_input['strategy3_input']):
            memory[strat3ref + i] = val
    %}

    let (local strats : felt*) = alloc();
    memcpy(strats, strat1, 3);
    memcpy(strats + 3, strat2, 2);
    memcpy(strats + 5, strat3, 4);

    let (input_hash) = keccak_felts(9, strats);
    let (strat1_score) = calcul_score1(3, strat1, debt_ratio[0]);
    let (strat2_score) = calcul_score2(2, strat2, debt_ratio[1]);
    let (strat3_score) = calcul_score3(4, strat3, debt_ratio[2]);

    let final_score = strat1_score + strat2_score + strat3_score;
    let (vault_apy,r) = unsigned_div_rem(final_score, 10000);

    //Return the program input and output
    let (callback) = get_label_location(serialize_word_from_pointer);

    serialize_word(input_hash.high);
    serialize_word(input_hash.low);
    serialize_array(debt_ratio, 3, 1, callback);    
    serialize_word(vault_apy);
    return ();
}

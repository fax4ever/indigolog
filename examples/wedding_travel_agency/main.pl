/**
    Main file for running the simple Elevator examples.

    This file loads the interpreter and the application file, and has a main/0 and main/1 predicate to run the available controllers.

    This file needs to be combined after a configuration file, such as config.pl, is loaded (defining interpreter/1).
**/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSULT NECESSARY FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% top-level interpreter (interpreter/1 is defined in config.pl)
:- dir(indigolog_plain, F), consult(F).

% 4 - Consult application
:- [wta].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN PREDICATE - evaluate this to run demo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% main/0: Gets INDIGOLOG to evaluate a chosen mainControl procedure
main :-
    findall(C, proc(control(C), _), L),
    repeat,
    format('Controllers available: ~w\n', [L]),
    write('Select controller: '),
	read(S), nl,
    member(S, L),
	format('Executing controller: *~w*\n', [S]), !,
    indigolog(control(S)).

main(C) :- 	indigolog(control(C)).



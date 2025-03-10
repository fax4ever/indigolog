%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/* Transition System semantics for CONGOLOG and GOLOG

    Part of the INDIGOLOG system

    Refer to root directory for license, documentation, and inforamtion.
*/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            TRANS and FINAL
% Trans(E, H, E1, H1) ->  One execution step of program E from history H
%			 leads to program E1 with history H1.
% Final(E, H)       ->  Program E at history H is final.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    /* CONGOLOG CONSTRUCTS                                           */
    /*    iconc(E)    : iterative concurrent execution of E              */
    /*    conc(E1, E2) : concurrent (interleaved) execution of E1 and E2  */
    /*    pconc(E1, E2): prioritized conc. execution of E1 and E2 (E1>E2) */
    /*    pconc2(E1, E2, H): used to improve  performance of pconc(_, _) */
    /*                                                                   */
final(iconc(_), _).
final(conc(E1, E2), H) :- final(E1, H), final(E2, H).
final(pconc(E1, E2), H) :- final(E1, H), final(E2, H).

trans(iconc(E), H, conc(E1, iconc(E)), H1) :- trans(E, H, E1, H1).
trans(conc(E1, E2), H, conc(E, E2), H1) :- trans(E1, H, E, H1).
trans(conc(E1, E2), H, conc(E1, E), H1) :- trans(E2, H, E, H1).
trans(pconc(E1, E2), H, E, H1) :-    % pconc2(E1, E2, H) is for when E1 blocked at H
    trans(E1, H, E3, H1) -> E = pconc(E3, E2) ; trans(pconc2(E1, E2, H), H, E, H1).

% pconc2(E1, E2, H) does not reconsider process E1 as long as the history
% remains being H (at H, E1 is already known to be blocked)
trans(pconc2(E1, E2, H), H, E, H1) :- !,
    trans(E2, H, E3, H1),  % blocked history H
    (H1 = H -> E = pconc2(E1, E3, H) ; E = pconc(E1, E3)).
trans(pconc2(E1, E2, _), H, E, H1) :- trans(pconc(E1, E2), H, E, H1).


       /* INTERRUPTS (page 121 CONGOLOG paper*/
% realized with an if-then-else construct bc test ?(.) is not blocking!
% we make the check for interrupts_running more efficiently via assert/retract
% TODO: check issue: https://github.com/ssardina-agts/indigolog/issues/4
trans(interrupt(Trigger, Body), H, E1, H1) :-
    trans(while(interrupts_running, if(Trigger, Body, ?(neg(true)))), H, E1, H1).

trans(interrupt(V, Trigger, Body), H, E1, H1) :-
    trans(while(interrupts_running,
    		pi(V, if(Trigger, Body, ?(neg(true))))), H, E1, H1).

final(interrupt(Trigger, Body), H) :-
    final(while(interrupts_running, if(Trigger, Body, ?(neg(true)))), H).

final(interrupt(V, Trigger, Body), H) :-
    final(while(interrupts_running, pi(V, if(Trigger, Body, ?(neg(true))))), H).

% convert prioritized_interrupts into a nested pconc/2 of simple interrupts
%   pconc(interrupt(.), pconc(interrupt(.), pconc(interrup(.),...)))
trans(prioritized_interrupts(L), H, E1, H1) :-
    assert(interrupts_running),
    expand_interrupts(L, E), !,
    trans(E, H, E1, H1).

expand_interrupts([], stop_interrupts). % if all bocked: stop interrupts!
expand_interrupts([X|L], pconc(X, E)) :-
    expand_interrupts(L, E).

% trans(stop_interrupts, H, [], [stop_interrupts|H]).   % as paper, but inefficient

% action must be in history to unlock pconc2() and flush all interrupts!
trans(stop_interrupts, H, [], [trans(stop_interrupts)|H]) :- retract(interrupts_running).
final(stop_interrupts, _) :- fail, !.

% we must load this BEFORE any holds/2 from projector!
holds(interrupts_running, _) :- !, interrupts_running.
holds(neg(interrupts_running), H) :- !, \+ holds(interrupts_running, H).




    /* GOLOG CONSTRUCTS                                           */
    /*                                                                */
    /*  These include primitive action, test, while, pick, if         */
    /*  nondeterministic choice and nondeterministic iteration.	      */
    /*								      */
final([], _).
final(star(_), _).
final(star(_, _), _).
final([E|L], H) :- final(E, H), final(L, H).
final(ndet(E1, E2), H) :- final(E1, H) ; final(E2, H).
final(if(P, E1, E2), H) :- ground(P), !, (holds(P, H) -> final(E1, H) ; final(E2, H)).
final(if(P, E1, _), H) :- holds(P, H), final(E1, H).
final(if(P, _, E2), H) :- holds(neg(P), H), final(E2, H).
final(while(P, E), H) :- holds(neg(P), H) ; final(E, H).

final(pi([], E), H) :- !, final(E, H).
final(pi([V|L], E), H) :- !, final(pi(L, pi(V, E)), H).
final(pi(V, E), H) :- !, subv(V, _, E, E2), !, final(E2, H).
final(pi((V, D), E), H) :- !, final(pi(V, D, E), H).
final(pi(V, D, E), H) :- domain(W, D), subv(V, W, E, E2), !, final(E2, H).

final(E, H) :- proc(E, E2), !, final(E2, H).


trans([E|L], H, E1, H2) :- \+ L = [], final(E, H), trans(L, H, E1, H2).
trans([E], H, E1, H1) :- !, trans(E, H, E1, H1). % avoids lots nested lists on whiles()
trans([E|L], H, [E1|L], H2) :- trans(E, H, E1, H2).
trans(?(P), H, [], H) :- holds(P, H).
trans(ndet(E1, E2), H, E, H1) :- trans(E1, H, E, H1) ; trans(E2, H, E, H1).
trans(if(P, E1, E2), H, E, H1) :- ground(P), !,
	(holds(P, H) -> trans(E1, H, E, H1) ;  trans(E2, H, E, H1)).
trans(if(P, E1, _), H, E, H1) :- holds(P, H), !, trans(E1, H, E, H1).
trans(if(P, _, E2), H, E, H1) :- !, holds(neg(P), H), trans(E2, H, E, H1).
trans(star(E, 1), H, E1, H1) :- !, trans(E, H, E1, H1).
trans(star(E, N), H, [E1, star(E, M)], H1) :- N > 1, M is N - 1, trans(E, H, E1, H1).
trans(star(E), H, E1, H1) :- trans(E, H, E1, H1).
trans(star(E), H, [E1, star(E)], H1) :- trans(E, H, E1, H1).
trans(while(P, E), H, [E1, while(P, E)], H1) :- holds(P, H), trans(E, H, E1, H1).

trans(pi([], E), H, E1, H1) :- !, trans(E, H, E1, H1).
trans(pi([V|L], E), H, E1, H1) :- !, trans(pi(L, pi(V, E)), H, E1, H1).
trans(pi((V, D), E), H, E1, H1) :- !, trans(pi(V, D, E), H, E1, H1).
trans(pi(r(V), D, E), H, E1, H1) :- !, rdomain(W, D), subv(V, W, E, E2), trans(E2, H, E1, H1).
trans(pi(V, D, E), H, E1, H1) :- !, domain(W, D), subv(V, W, E, E2), trans(E2, H, E1, H1).
trans(pi(V, E), H, E1, H1) :- subv(V, _, E, E2), !, trans(E2, H, E1, H1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAST TRANS FOR PROCEDURES AND PRIMITIVE ACTIONS (everything else failed)
% Replace the arguments by their value, check that it is a primitive action
% and finally check for preconditions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trans(E, H, E1, H1) :- proc(E, E2), !, trans(E2, H, E1, H1).
trans(A, H, [], [A|H]) :- system_action(A), !.
final(A, _) :- system_action(A), !, fail.

% E is an action whose precondition is true!
trans(A, H, [], [A1|H]) :-
	calc_arg(A, A1, H),
	prim_action(A1),
	poss(A1, P),
	holds(P, H).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
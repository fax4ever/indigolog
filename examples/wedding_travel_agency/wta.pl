% Interface to the outside world via read and write
execute(A, SR) :- ask_execute(A, SR).
exog_occurs(_) :- fail.

% Domain Specification in Situation Calculus

% Non-fluents (you can see them as a relation DB tuples - closed world assumption)

place(P) :- member(P, [bamberg, nurnberg, regensburg, munchen, lindau, bregenz, fussen, innsbruck, 
rothenburg, wurzburg, rome, bologna, ettal]).

hotel(H) :- member(H, [hotelEuropaBamberg, parkInnNurnberg, ibisStylesRegensburg, boutiqueHotelMunchen, 
hotelEngelLindau, ibisBregenz, hotelSchlosskroneFussen, youthHostelInnsbruck, hotelRothenburgerHof, 
hotelStraussWurzburg, klosterhotelEttal, hotelPalaceBologna]).

attraction(A) :- member(A, [neuschwansteinCastle, ettalAbbey, schlossLinderhof, lindauHafen, hohesSchloss, 
pfander, rothenburgObDerTauber, wurzburgResidence, bambergOldTown, imperialCastleOfNuremberg, 
altesRathausRegensburg, munichResidence, schlossNymphenburg, piazzaMaggiore]).

% travel(from, to, time, cost, type)

travel(rome, munchen, 120, 200, air).
travel(munchen, rome, 120, 200, air).

travel(rome, bologna, 120, 67, train).
travel(bologna, rome, 120, 67, train).

travel(bologna, innsbruck, 300, 45, train).
travel(innsbruck, bologna, 300, 45, train).

travel(bologna, munchen, 420, 70, train).
travel(munchen, bologna, 420, 70, train).

travel(wurzburg, bamberg, 60, 6, car).
travel(bamberg, wurzburg, 60, 6, car).

travel(wurzburg, rothenburg, 41, 4, car).
travel(rothenburg, wurzburg, 41, 4, car).

travel(bamberg, rothenburg, 89, 9, car).
travel(rothenburg, bamberg, 89, 9, car).

travel(bamberg, nurnberg, 52, 5, car).
travel(nurnberg, bamberg, 52, 5, car).

travel(nurnberg, rothenburg, 75, 7, car).
travel(rothenburg, nurnberg, 75, 7, car).

travel(nurnberg, regensburg, 79, 8, car).
travel(regensburg, nurnberg, 79, 8, car).

travel(regensburg, munchen, 75, 8, car).
travel(munchen, regensburg, 75, 8, car).

travel(nurnberg, munchen, 121, 12, car).
travel(munchen, nurnberg, 121, 12, car).

travel(rothenburg, munchen, 167, 17, car).
travel(munchen, rothenburg, 167, 17, car).

travel(rothenburg, fussen, 143, 14, car).
travel(fussen, rothenburg, 143, 14, car).

travel(rothenburg, lindau, 142, 14, car).
travel(lindau, rothenburg, 142, 14, car).

travel(lindau, munchen, 128, 12, car).
travel(munchen, lindau, 128, 12, car).

travel(lindau, fussen, 77, 8, car).
travel(fussen, lindau, 77, 8, car).

travel(lindau, bregenz, 16, 2, car).
travel(bregenz, lindau, 16, 2, car).

travel(bregenz, innsbruck, 129, 13, car).
travel(innsbruck, bregenz, 129, 13, car).

travel(fussen, ettal, 46, 5, car).
travel(ettal, fussen, 46, 5, car).

travel(ettal, munchen, 66, 7, car).
travel(munchen, ettal, 66, 7, car).

travel(ettal, innsbruck, 69, 7, car).
travel(innsbruck, ettal, 69, 7, car).

travel(munchen, innsbruck, 121, 12, car).
travel(innsbruck, munchen, 121, 12, car).

% hotel_info(hotel, place, cost)

hotel_info(hotelEuropaBamberg, bamberg, 89).
hotel_info(parkInnNurnberg, nurnberg, 80).
hotel_info(ibisStylesRegensburg, regensburg, 138).
hotel_info(boutiqueHotelMunchen, munchen, 170).
hotel_info(hotelEngelLindau, lindau, 150).
hotel_info(ibisBregenz, bregenz, 94).
hotel_info(hotelSchlosskroneFussen, fussen, 134).
hotel_info(youthHostelInnsbruck, innsbruck, 88).
hotel_info(hotelRothenburgerHof, rothenburg, 70).
hotel_info(hotelStraussWurzburg, wurzburg, 89).
hotel_info(klosterhotelEttal, ettal, 143).
hotel_info(hotelPalaceBologna, bologna, 115).

% attraction_info(attraction, place, time, cost)

attraction_info(neuschwansteinCastle, fussen, 240, 21).
attraction_info(ettalAbbey, ettal, 60, 0).
attraction_info(schlossLinderhof, ettal, 120, 10).
attraction_info(lindauHafen, lindau, 120, 0).
attraction_info(hohesSchloss, fussen, 60, 5).
attraction_info(pfander, bregenz, 60, 10).
attraction_info(rothenburgObDerTauber, rothenburg, 120, 0).
attraction_info(wurzburgResidence, wurzburg, 120, 10).
attraction_info(bambergOldTown, bamberg, 120, 0).
attraction_info(imperialCastleOfNuremberg, nurnberg, 60, 7).
attraction_info(altesRathausRegensburg, regensburg, 30, 0).
attraction_info(munichResidence, munchen, 90, 10).
attraction_info(schlossNymphenburg, munchen, 120, 10).
attraction_info(piazzaMaggiore, bologna, 20, 0).

% Fluents

prim_fluent(at(P)) :- place(P).
prim_fluent(visited(A)) :- attraction(A).
prim_fluent(day_activity_minutes).
prim_fluent(days).
prim_fluent(attractions_visited).
prim_fluent(total_cost).

% Actions

prim_action(move(P)) :- place(P). 
prim_action(visit(A)) :- attraction(A).
prim_action(rest(H)) :- hotel(H).

% Precondition Axioms

poss(move(To), and(
    and(at(From), travel(From, To, Time, _, _)),
    % each day I can spend no more than 10 hours moving and visting stuff %
    =<(+(day_activity_minutes, Time), 600)
)).

poss(visit(A), and(
    and(neg(visited(A)),at(P)),
    and(attraction_info(A, P, Time, _),
        % each day I can spend no more than 10 hours moving and visting stuff %
        =<(+(day_activity_minutes, Time), 600))
)).

poss(rest(H), and(
    at(P),
    hotel_info(H, P, _)
)).

% Effect Axioms (SSA are derived by the engine automatically)

causes_val(move(To), at(From), false, and(
    at(From),
    travel(From, To, _, _, _)
)).
causes_val(move(To), at(To), true, true).
causes_val(move(To), day_activity_minutes, N, and(
    and(at(From),
    travel(From, To, Time, _, _)),
    N is day_activity_minutes + Time
)).
causes_val(move(To), total_cost, N, and(
    and(at(From),
    travel(From, To, _, Cost, _)),
    N is total_cost + Cost
)).

causes_val(visit(A), day_activity_minutes, N,
    and(attraction_info(A, _, Time, _), N is day_activity_minutes + Time)).
causes_val(visit(A), total_cost, t, N,
    and(attraction_info(A, _, _, Cost), N is total_cost + Cost)).
causes_val(visit(A), visited(A), true, true).
causes_val(visit(_), attractions_visited, N, N is attractions_visited + 1).

causes_val(rest(H), total_cost, N, and(
    hotel_info(H, _, Cost), N is total_cost + Cost)).
causes_val(rest(_), day_activity_minutes, 0, true).
causes_val(rest(_), days, N, N is days + 1).

% Init

initially(at(P), true) :- =(P, rome).
initially(at(P), false) :- place(P), \+ initially(at(P), true).
initially(day_activity_minutes, 0).
initially(days, 0).
initially(attractions_visited, 0).
initially(total_cost, 0).

% Utility procedure

% We want to tendentially avoid to pass more times in a place 
% for which we visited all the attractions

proc(attraction_not_visited(P), 
    some(A, and(attraction_info(A, P, _, _), neg(visited(A))))
).

proc(no_attraction(P),
    neg(some(A, attraction_info(A, P, _, _)))
).

% Trying to prioritazie the places in which there
% are some non visited attractions (this is a sort of heuristic)
% or at least having no attractions

proc(smart_move(P), [?(attraction_not_visited(P)), move(P)]).

proc(neutral_move(P), [?(no_attraction(P)), move(P)]).

% Definitions of non-deterministically procedures

proc(pi_visit, pi(a, visit(a))).
proc(pi_smart_move, pi(to, smart_move(to))).
proc(pi_neutral_move, pi(to, neutral_move(to))).
proc(pi_move, pi(to, move(p))).
proc(pi_rest, pi(h, rest(h))).

% Prioritize them - try to make more visits possible!
% this works preatty well compared to a random walk search

proc(pi_any, ndet(ndet(pi_visit, ndet(pi_smart_move, pi_neutral_move)), ndet(pi_rest, pi_move))).

% single steps tests:
proc(control(test1), [move(munchen), move(nurnberg),
rest(parkInnNurnberg), visit(imperialCastleOfNuremberg), move(bamberg)]).

proc(control(test2), [move(bamberg)]).

proc(control(test3), search([pi_any, pi_any, pi_any, pi_any])).

% domain-dependent-heuristic-walk for 2 days
proc(control(test4), search(while(days < 2, pi_any))).

% try to visit N attractions in at most D days
proc(find_n_attractions(N, D), while(attractions_visited < N, 
    [?(days =< D), pi_any]
)).

% test find_n_attractions
proc(control(test5), search(find_n_attractions(5, 1))).

% PROBLEM 1 %
% Given a hotel, find all the attractions I can reach there in a given amount of time, using
% airplanes, trains or renting a car

proc(maximise_attraction(N, D),  % reverse iterative deepening search starting with attactions to visit
    ndet( find_n_attractions(N, D), 
    [?(N >= 0), pi(n, [?(n is N - 1), maximise_attraction(n, D)])]
)).

% try to visit 14 attractions / not possible %
proc(control(problem1), search(maximise_attraction(14, 1))).




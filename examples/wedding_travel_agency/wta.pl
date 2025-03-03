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
travel(wurzburg, bamberg, 60, 6, car).
travel(wurzburg, rothenburg, 41, 4, car).
travel(bamberg, rothenburg, 89, 9, car).
travel(bamberg, nurnberg, 52, 5, car).
travel(nurnberg, rothenburg, 75, 7, car).
travel(nurnberg, regensburg, 79, 8, car).
travel(regensburg, munchen, 75, 8, car).
travel(nurnberg, munchen, 121, 12, car).
travel(rothenburg, munchen, 167, 17, car).
travel(rothenburg, fussen, 143, 14, car).
travel(rothenburg, lindau, 142, 14, car).
travel(lindau, munchen, 128, 12, car).
travel(lindau, fussen, 77, 8, car).
travel(lindau, bregenz, 16, 2, car).
travel(bregenz, innsbruck, 129, 13, car).
travel(fussen, ettal, 46, 5, car).
travel(ettal, munchen, 66, 7, car).
travel(ettal, innsbruck, 69, 7, car).
travel(munchen, innsbruck, 121, 12, car).

% any travel can be done in both directions

travel(X, Y, _, _) :- travel(Y, X, _, _).

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

% each day I can spend no more than 10 hours moving and visting stuff %

max_day_activity_minutes(600).

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
    at(From),
    travel(From, To, _, _, _)
    % re-add condition:
    % travel(From, To, Time, _, _),
    % neg(day_activity_minutes + Time > max_day_activity_minutes)
)).

poss(visit(A), and(
    neg(visited(A)),
    at(P),
    attraction_info(A, P, Time, _),
    neg(day_activity_minutes + Time > max_day_activity_minutes)
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
causes_val(move(To), day_activity_minutes, day_activity_minutes + Time, and(
    at(From),
    travel(From, To, Time, _, _)
)).
causes_val(move(To), total_cost, total_cost + Cost, and(
    at(From),
    travel(From, To, _, Cost, _)
)).

causes_val(visit(A), day_activity_minutes, day_activity_minutes + Time, attraction_info(A, _, Time, _)).
causes_val(visit(A), total_cost, total_cost + Cost, attraction_info(A, _, _, Cost)).
causes_val(visit(A), visited(A), true, true).
causes_val(visit(_), attractions_visited, attractions_visited + 1, true).

causes_val(rest(H), total_cost, total_cost + Cost, hotel_info(H, _, Cost)).
causes_val(rest(_), day_activity_minutes, 0, true).
causes_val(rest(_), days, days + 1, true).

% Init

initially(at(P), true) :- =(P, rome).
initially(at(P), false) :- place(P), \+ initially(at(P), true).
initially(day_activity_minutes, 0).
initially(days, 0).
initially(attractions_visited, 0).
initially(total_cost, 0).

% Definitions of complex conditions

proc(target(N), neg(attractions_visited < N)).

proc(within_days(N), neg(days > N)).

% Definitions of complex actions

% all actions with non-deterministically chosen parameters
proc(pi_move, pi([to], move(to))).
proc(pi_visit, pi([a], visit(a))).
proc(pi_rest, pi([h], rest(h))).

% choosing randomly between all 3 actions
proc(choose_action, ndet(pi_move, pi_visit, pi_rest)).

% control: full_search
proc(full_search, [star(choose_action), ?(target(1))]).
proc(control(full_search), search(full_search)).

% test controls:
proc(control(test1), [move(munchen)]).
proc(control(test2), [move(bamberg)]).





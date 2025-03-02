% Interface to the outside world via read and write
execute(A, SR) :- ask_execute(A, SR).
exog_occurs(_) :- fail.

% Domain Specification in Situation Calculus

% Non-fluents (you can see them as a relation DB tuples - closed world assumption)

place(P) :- member(P, [bamberg, nurnberg, regensburg, munchen, lindau, bregenz, fussen, innsbruck, 
rothenburg, wurzburg, rome, bologna, ettal]).

% hotel(name, place, time, cost, type)

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

% hotel(name, place, cost)

hotel(hotelEuropaBamberg, bamberg, 89).
hotel(parkInnNurnberg, nurnberg, 80).
hotel(ibisStylesRegensburg, regensburg, 138).
hotel(boutiqueHotelMunchen, munchen, 170).
hotel(hotelEngelLindau, lindau, 150).
hotel(ibisBregenz, bregenz, 94).
hotel(hotelSchlosskroneFussen, fussen, 134).
hotel(youthHostelInnsbruck, innsbruck, 88).
hotel(hotelRothenburgerHof, rothenburg, 70).
hotel(hotelStraussWurzburg, wurzburg, 89).
hotel(klosterhotelEttal, ettal, 143).
hotel(hotelPalaceBologna, bologna, 115).

% attraction(name, place, time, cost)

attraction(neuschwansteinCastle, fussen, 240, 21).
attraction(ettalAbbey, ettal, 60, 0).
attraction(schlossLinderhof, ettal, 120, 10).
attraction(lindauHafen, lindau, 120, 0).
attraction(hohesSchloss, fussen, 60, 5).
attraction(pfander, bregenz, 60, 10).
attraction(rothenburgObDerTauber, rothenburg, 120, 0).
attraction(wurzburgResidence, wurzburg, 120, 10).
attraction(bambergOldTown, bamberg, 120, 0).
attraction(imperialCastleOfNuremberg, nurnberg, 60, 7).
attraction(altesRathausRegensburg, regensburg, 30, 0).
attraction(munichResidence, munchen, 90, 10).
attraction(schlossNymphenburg, munchen, 120, 10).
attraction(piazzaMaggiore, bologna, 20, 0).

max_day_activity_minutes(600).

% Fluents

prim_fluent(at(P)) :- place(P).
prim_fluent(visited(N)) :- attraction(N, _, _, _).
prim_fluent(day_activity_minutes).
prim_fluent(days).
prim_fluent(attractions_visited).
prim_fluent(total_cost).

% Actions

prim_action(move(From, To, Time, Cost)) :- travel(From, To, Time, Cost, _).
prim_action(visit(Name, Place, Time, Cost)) :- attraction(Name, Place, Time, Cost).
prim_action(rest(Name, Place, Cost)) :- hotel(Name, Place, Cost).

% Precondition Axioms

poss(move(From, _, Time, _), and(
    at(From),
    neg(day_activity_minutes + Time > max_day_activity_minutes)
)).

poss(visit(Name, Place, Time, _), and(
    neg(visited(Name)),
    at(Place),
    neg(day_activity_minutes + Time > max_day_activity_minutes)
)).

poss(rest(_, Place, _), at(Place)).

% Effect Axioms (SSA are derived by the engine automatically)

causes_val(move(From, _, _, _), at(From), false, true).
causes_val(move(_, To, _, _), at(To), true, true).
causes_val(move(_, _, Time, _), day_activity_minutes, day_activity_minutes + Time, true).
causes_val(move(_, _, _, Cost), total_cost, total_cost + Cost, true).

causes_val(visit(_, _, Time, _), day_activity_minutes, day_activity_minutes + Time, true).
causes_val(visit(_, _, _, Cost), total_cost, total_cost + Cost, true).
causes_val(visit(Name, _, _, _), visited(Name), true, true).
causes_val(visit(_, _, _, _), attractions_visited, attractions_visited + 1, true).

causes_val(rest(_, _, _, Cost), total_cost, total_cost + Cost, true).
causes_val(rest(_, _, _, _), day_activity_minutes, 0, true).
causes_val(rest(_, _, _, _), days, days + 1, true).

% Init

initially(at(rome), true).
initially(day_activity_minutes, 0).
initially(days, 0).
initially(attractions_visited, 0).
initially(total_cost, 0).

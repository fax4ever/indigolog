% Interface to the outside world via read and write
execute(A, SR) :- ask_execute(A, SR).
exog_occurs(_) :- fail.

% Domain Specification in Situation Calculus

place(P) :- member(P, [bamberg, nurnberg, regensburg, munchen, lindau, bregen, fussen, innsbruck, 
rothenburg, wurzburg, rome, bologna, ettal]).

hotel(H) :- member(H, [hotelEuropaBamberg, parkInnNurnberg, ibisStylesRegensburg, boutiqueHotelMunchen, 
hotelEngelLindau, ibisBregenz, hotelSchlosskroneFussen, youthHostelInnsbruck, hotelRothenburgerHof, 
hotelStraussWurzburg, klosterhotelEttal, hotelPalaceBologna]).

attraction(A) :- member(A, [neuschwansteinCastle, ettalAbbey, schlossLinderhof, lindauHafen, 
hohesSchloss, pfander, rothenburgObDerTauber, wurzburgResidence, bambergOldTown, 
imperialCastleOfNuremberg, altesRathausRegensburg, munichResidence, schlossNymphenburg, piazzaMaggiore]).

% Use compound terms as non-fluents predicates / functions
travel(rome, munchen, 120, 200).
travel(rome, bologna, 120, 67).
travel(bologna, innsbruck, 300, 45).
travel(bologna, munchen, 420, 70).
travel(wurzburg, bamberg, 60, 6).
travel(wurzburg, rothenburg, 41, 4).
travel(bamberg, rothenburg, 89, 9).
travel(bamberg, nurnberg, 52, 5).
travel(nurnberg, rothenburg, 75, 7).
travel(nurnberg, regensburg, 79, 8).
travel(regensburg, munchen, 75, 8).
travel(nurnberg, munchen, 121, 12).
travel(rothenburg, munchen, 167, 17).
travel(rothenburg, fussen, 143, 14).
travel(rothenburg, lindau, 142, 14).
travel(lindau, munchen, 128, 12).
travel(lindau, fussen, 77, 8).
travel(lindau, bregenz, 16, 2).
travel(bregenz, innsbruck, 129, 13).
travel(fussen, ettal, 46, 5).
travel(ettal, munchen, 66, 7).
travel(ettal, innsbruck, 69, 7).
travel(munchen, innsbruck, 121, 12).

cost(hotelEuropaBamberg, 89)
cost(parkInnNurnberg, 80)
cost(ibisStylesRegensburg, 138)
cost(boutiqueHotelMunchen, 170)
cost(hotelEngelLindau, 150)
cost(ibisBregenz, 94)
cost(hotelSchlosskroneFussen, 134)
cost(youthHostelInnsbruck, 88)
cost(hotelRothenburgerHof, 70)
cost(hotelStraussWurzburg, 89)
cost(klosterhotelEttal, 143)
cost(hotelPalaceBologna, 115)

att(neuschwansteinCastle, 240, 21)
att(ettalAbbey, 60, 0)
att(schlossLinderhof, 120, 10)
att(lindauHafen, 120, 0)
att(hohesSchloss, 60, 5)
att(pfander, 60, 10)
att(rothenburgObDerTauber, 120, 0)
att(wurzburgResidence, 120, 10)
att(bambergOldTown, 120, 0)
att(imperialCastleOfNuremberg, 60, 7)
att(altesRathausRegensburg, 30, 0)
att(munichResidence, 90, 10)
att(schlossNymphenburg, 120, 10)
att(piazzaMaggiore, 20, 0)

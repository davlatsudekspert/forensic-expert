"""Entries part 5: ibuprofen, diphenhydramine, lidocaine (teaching complex 2025)."""
from sm_core import N, colour, generic, loc, micro, tlc, uv
from substance_methods_data import E, add

add(colour("ibuprofen", "liebermann", ["orange"], "TOKS", loc("TOKS", pdf=139)))
add(tlc("ibuprofen", [("CHCl3", 9), ("MeOH", 1)], "not_stated", "marquis", "TOKS", loc("TOKS", pdf=139),
        rf=[(None, "0.54")],
        note=N("The source prints Rf for several anti-inflammatory drugs in this system (diclofenac 0.47, indometacin 0.38, ketoprofen 0.57, piroxicam 0.48), so the values are close and need standards on the same plate.",
               "Manba bu tizimda bir necha yallig‘lanishga qarshi vosita uchun Rf keltiradi (diklofenak 0,47, indometatsin 0,38, ketoprofen 0,57, piroksikam 0,48), shuning uchun qiymatlar yaqin va xuddi shu plastinkada standartlar kerak.",
               "Источник приводит Rf для нескольких противовоспалительных средств в этой системе (диклофенак 0,47, индометацин 0,38, кетопрофен 0,57, пироксикам 0,48), поэтому значения близки и нужны стандарты на той же пластинке.")))
add(uv("ibuprofen", N("96% ethanol", "96% etanol", "96% этаноле"), ["257", "263", "272"], "TOKS", loc("TOKS", pdf=139)))
add(generic("ibuprofen", "physical",
            N("Melting point of ibuprofen: 75–77 °C.", "Ibuprofenning suyuqlanish harorati: 75–77 °C.", "Температура плавления ибупрофена: 75–77 °C."),
            "TOKS", loc("TOKS", pdf=138), "physical", "physical", cat="C"))
add(colour("diphenhydramine", "sulfuric", ["yellow", "red-brown"], "TOKS", loc("TOKS", pdf=130), timing="on_standing",
           note=N("The colour disappears on adding a few drops of water (the complex decomposes). The source calls the red colour brick-red.",
                  "Bir necha tomchi suv qo‘shilganda rang yo‘qoladi (kompleks parchalanadi). Manba qizil rangni g‘isht rangli deb ataydi.",
                  "Окраска исчезает при добавлении нескольких капель воды (комплекс разрушается). Источник называет красный цвет кирпично-красным.")))
add(colour("diphenhydramine", "marquis", ["lemon-yellow"], "TOKS", loc("TOKS", pdf=130)))
add(colour("diphenhydramine", "liebermann", ["orange"], "TOKS", loc("TOKS", pdf=130)))
add(colour("diphenhydramine", "mandelin", ["yellow"], "TOKS", loc("TOKS", pdf=130)))
add(tlc("diphenhydramine", [("CHCl3", 12), ("Me2CO", 24), ("NH3", 1)], "not_stated", "h2so4_drop", "TOKS", loc("TOKS", pdf=130),
        rf=[(None, "0.58–0.60")],
        note=N("Spot colour: yellow; the metabolite benzhydrol gives a spot at Rf 0.76–0.80 in the same system.",
               "Dog‘ rangi: sariq; metabolit benzgidrol xuddi shu tizimda Rf 0,76–0,80 da dog‘ beradi.",
               "Цвет пятна: жёлтый; метаболит бензгидрол даёт в той же системе пятно при Rf 0,76–0,80.")))
add(uv("diphenhydramine", N("0.1 N sulfuric acid", "0,1 n sulfat kislota", "0,1 н серной кислоте"), ["252", "257"], "TOKS", loc("TOKS", pdf=130)))
add(micro("lidocaine",
          N("Cobalt nitrate solution (a few drops): after a short time a blue-green crystalline precipitate.",
            "Kobalt nitrat eritmasi (bir necha tomchi): biroz turgandan keyin ko‘k-yashil kristall cho‘kma.",
            "Раствор нитрата кобальта (несколько капель): через короткое время сине-зелёный кристаллический осадок."),
          "TOKS", loc("TOKS", pdf=129), reagents=["cobalt nitrate"]))

from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv  # NOQA


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },

    index_date = "2020-11-10",

    population=patients.satisfying(
        """registered AND 
        enrolled""",

        registered=patients.registered_as_of("index_date"),

        enrolled=patients.registered_practice_as_of(
            "index_date",
            returning="rct__germdefence__enrolled",
            return_expectations={
                "incidence": 0.99,
            },
        )
    ),

    age=patients.age_as_of(
    "index_date",
    return_expectations={
        "rate" : "universal",
        "int" : {"distribution" : "population_ages"}
        }
    ),

    sex=patients.sex(
    return_expectations={
        "rate": "universal",
        "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    practice_trial_arm=patients.registered_practice_as_of(
        "index_date",
        returning="rct__germdefence__trial_arm",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "con": 0.5,
                    "int": 0.5
                },
            },
        },
    ),

    #Deprivation score as a percentile
    practice_deprivation_pctile=patients.registered_practice_as_of(
        "index_date",
        returning="rct__germdefence__deprivation_pctile",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "5": 0.1,
                    "15": 0.1,
                    "25": 0.1,
                    "35": 0.1,
                    "45": 0.1,
                    "55": 0.1,
                    "65": 0.1,
                    "75": 0.1,
                    "85": 0.1,
                    "95": 0.1
                },
            },
        },
    ),
    
    #Proportion of patients identifying as belonging to an ethnic minority
    practice_ethmin=patients.registered_practice_as_of(
        "index_date",
        returning="rct__germdefence__minority_ethnic_total",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "NA": 0.5,
                    "0.1": 0.1,
                    "0.3": 0.1,
                    "0.5": 0.1,
                    "0.7": 0.1,
                    "0.9": 0.1                    
                },
            },
        },
    ),

    #Number of visits to the Germ Defence website
    practice_n_visits=patients.registered_practice_as_of(
        "index_date",
        returning="rct__germdefence__n_visits_practice",
            return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "NA": 0.5,
                    "2": 0.1,
                    "5": 0.1,
                    "10": 0.1,
                    "50": 0.1,
                    "100": 0.1                    
                },
            },
        },
    ),

    #GP practice ID
    practice_id=patients.registered_practice_as_of(
        "2020-11-10",
        returning="pseudo_id",
        return_expectations={
        "rate" : "universal",
        "int" : {"distribution" : "normal", "mean": 1500, "stddev": 15},
        },
    ),
)

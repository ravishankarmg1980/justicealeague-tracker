package com.justiceleague.justiceleaguetracker.service;

import com.justiceleague.justiceleaguetracker.dto.SuperHero;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

import java.net.InetAddress;

/**
 * This class provides the functionality for the justice league tracker.
 *
 * @author dinuka
 */
@Service
public class JusticeLeagueServiceImpl implements JusticeLeagueService {

    private static Logger log = LoggerFactory.getLogger(JusticeLeagueService.class);

    @Override
    public List<SuperHero> getJusticeLeague() {
        log.info("Received a request to get all the justice league members");
        return populateJusticeLeague();
    }

    private List<SuperHero> populateJusticeLeague() throws Exception{
		
		SuperHero superMan = new SuperHero("Clark Kent (from "  + System.getenv("TEMP") + " )", Arrays.asList("Flight", "Super human strength",
                "X-ray vision"), "Metropolis");
        SuperHero flash = new SuperHero("Barry Allen", Arrays.asList("Super speed",
                "Tapping into the speed force", "Time travel"), "Central city");
        SuperHero batman = new SuperHero("Bruce Wayne", Arrays.asList("Super rich", "Cool Gadgets"),
                "Gotham");
        return Arrays.asList(superMan, flash, batman);
    }
}

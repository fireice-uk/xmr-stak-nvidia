
#pragma once

#include "autoAdjust.hpp"

#include "nvcc_code/cryptonight.h"
#include "jconf.h"
#include "console.h"

#include <vector>
#include <cstdio>
#include <iostream>

class autoAdjust
{    
public:

    autoAdjust()
    {
        size_t n = jconf::inst()->GetThreadCount();
                // evaluate config parameter for if auto adjustment is needed
        for(size_t i = 0; i < n; i++)
        {
            jconf::thd_cfg cfg;
            jconf::inst()->GetThreadConfig(i, cfg);
            cfgVec.push_back(cfg);
        }
    }

    /** print the adjusted values if needed
     *
     * Routine exit the application and print the adjusted values if needed else
     * nothing is happened.
     */
    void validateThreadConfig()
    {
        if( !needToAdjust() )
            return;

        printf("\nYour config file contains values defined with `null`.\n");
        printf("The miner evaluates your system and prints a suggestion for the section `gpu_threads_conf` to the terminal.\n");
        printf("The values are not optimal, please optimize the values by your own based on the suggestion.\n");
        printf("Please copy past the values to your config.\n");
        printf("\n***************************************************************\n\n");
        // evaluate config parameter for if auto adjustment is needed
        for(auto& cfg : cfgVec)
        {
            nvid_ctx ctx;

            ctx.device_id = (int)cfg.id;
            ctx.device_blocks = (int)cfg.blocks;
            ctx.device_threads = (int)cfg.threads;
            ctx.device_bfactor = (int)cfg.bfactor;
            ctx.device_bsleep = (int)cfg.bsleep;

        // set all evice option those marked as auto (-1) to a valid value
#ifndef _WIN32
            if(ctx.device_bfactor == -1)
            {
                ctx.device_bfactor = 0;
            }
            if(ctx.device_bsleep == -1)
            {
                ctx.device_bsleep = 0;
            }
#else
            // windows pass, try to avoid that windows kills the miner if the gpu is blocked for 2 seconds
            if(ctx.device_bfactor == -1)
            {
                ctx.device_bfactor = 6;
            }
            if(ctx.device_bsleep == -1)
            {
                ctx.device_bsleep = 25;
            }
#endif
            if( cuda_get_deviceinfo(&ctx) != 1 )
            {
                printer::inst()->print_msg(L0, "Setup failed for GPU %d. Exitting.\n", cfg.id);
                std::exit(0);
            }
            nvidCtxVec.push_back(ctx);
        }

        printThreadConfig();
        printf("\n**************** Press ENTER to exit! ***********************\n");
        std::cin.sync();
        std::cin.get();
        std::exit(0);
    }

private:

    /** check if one thread needs to be adjusted
     *
     * @return true if adjustment is needed else false
     */
    bool needToAdjust()
    {
        for(auto& cfg : cfgVec)
        {
            if(
                cfg.bfactor == -1 ||
                cfg.blocks == -1 ||
                cfg.bsleep == -1 ||
                cfg.threads == -1
            )
                return true;
        }
        return false;
    }
    
    void printThreadConfig()
    {
        printf("\"gpu_threads_conf\" : [\n");
        int i = 0;
        for(auto& ctx : nvidCtxVec)
        {
            printf("   { \"index\" : %i, \"threads\" : %i, \"blocks\" : %i, \"bfactor\" : %i, \"bsleep\" :  %i, \"affine_to_cpu\" : %s},\n",
                ctx.device_id,
                ctx.device_threads,
                ctx.device_blocks,
                ctx.device_bfactor,
                ctx.device_bsleep,
                cfgVec[i].cpu_aff ? "true" : "false"
            );
            ++i;
        }
        printf("],\n");
    }

    std::vector<jconf::thd_cfg> cfgVec;
    std::vector<nvid_ctx> nvidCtxVec;
};

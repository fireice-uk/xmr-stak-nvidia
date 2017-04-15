
#pragma once

#include "autoAdjust.hpp"

#include "nvcc_code/cryptonight.h"
#include "jconf.h"
#include "console.h"

#include <vector>
#include <cstdio>
#include <sstream>

class autoAdjust
{    
public:

    autoAdjust()
    {
        int deviceCount = 0;
        if(cuda_get_devicecount(&deviceCount) == 0)
            std::exit(0);
        // evaluate config parameter for if auto adjustment is needed
        for(int i = 0; i < deviceCount; i++)
        {
            jconf::thd_cfg cfg;
            jconf::inst()->GetThreadConfig(i, cfg);
            cfg.cpu_aff = 0;
            cfgVec.push_back(cfg);
        }
    }

    /** print the adjusted values if needed
     *
     * Routine exit the application and print the adjusted values if needed else
     * nothing is happened.
     */
    void printConfig()
    {
        printer::inst()->print_str("\nThe configuration for `gpu_threads_conf` in your config file is `null`.\n");
        printer::inst()->print_str("The miner evaluates your system and prints a suggestion for the section `gpu_threads_conf` to the terminal.\n");
        printer::inst()->print_str("The values are not optimal, please try to tweak the values based on the suggestion.\n");
        printer::inst()->print_str("Please copy past the block within the asterisks to your config.\n");
        printer::inst()->print_str("\n**************** Copy&Paste ****************\n\n");
        int i = 0;
        // evaluate config parameter for if auto adjustment is needed
        for(auto& cfg : cfgVec)
        {
            nvid_ctx ctx;

            ctx.device_id = i;
            // -1 trigger auto adjustment
            ctx.device_blocks = -1;
            ctx.device_threads = -1;

        // set all evice option those marked as auto (-1) to a valid value
#ifndef _WIN32
            ctx.device_bfactor = 0;
            ctx.device_bsleep = 0;
#else
            // windows pass, try to avoid that windows kills the miner if the gpu is blocked for 2 seconds
            ctx.device_bfactor = 6;
            ctx.device_bsleep = 25;
#endif
            if( cuda_get_deviceinfo(&ctx) != 1 )
            {
                printer::inst()->print_msg(L0, "Setup failed for GPU %d. Exitting.\n", cfg.id);
                std::exit(0);
            }
            nvidCtxVec.push_back(ctx);
            ++i;
        }

        printThreadConfig();
        printer::inst()->print_str("\n**************** Copy&Paste ****************\n");

    }

private:
    
    void printThreadConfig()
    {
        printer::inst()->print_str("\"gpu_threads_conf\" : [\n");
        int i = 0;
        for(auto& ctx : nvidCtxVec)
        {
            std::stringstream conf;
            conf << "  { \"index\" : " << ctx.device_id << ",\n" <<
                "    \"threads\" : " << ctx.device_threads << ", \"blocks\" : " << ctx.device_blocks << ",\n" <<
                "    \"bfactor\" : " << ctx.device_bfactor << ", \"bsleep\" :  " << ctx.device_bsleep << ",\n" <<
                "    \"affine_to_cpu\" : " << ( cfgVec[i].cpu_aff ? "true" : "false" ) << ",\n" <<
                "  },\n";
            printer::inst()->print_str(conf.str().c_str());
            ++i;
        }
        printer::inst()->print_str("],\n");
    }

    std::vector<jconf::thd_cfg> cfgVec;
    std::vector<nvid_ctx> nvidCtxVec;
};

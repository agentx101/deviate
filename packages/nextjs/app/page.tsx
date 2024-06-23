"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { Address } from "~~/components/scaffold-stark";
import { useAccount } from "@starknet-react/core";
import { Address as AddressType } from "@starknet-react/chains";
import { useState, useEffect, use } from "react";
import { useScaffoldReadContract } from "~~/hooks/scaffold-stark/useScaffoldReadContract";
import { useDeployedContractInfo, useTransactor } from "~~/hooks/scaffold-stark";
import { useContractRead, useNetwork } from "@starknet-react/core";
import { useScaffoldMultiWriteContract } from "~~/hooks/scaffold-stark/useScaffoldMultiWriteContract";
import axios from "axios";
import { useTargetNetwork } from "~~/hooks/scaffold-stark/useTargetNetwork";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const [balance, setBalance] = useState<number | null>(null);

  // const { data: balanceData } = useScaffoldReadContract({
  //   contractName: "DevDock",
  //   functionName: "get_balance",
  //   args: [connectedAddress as AddressType],
  // });

  const { writeAsync: receiveAll } = useScaffoldMultiWriteContract({
    calls: [{contractName: "DevDock",
    functionName: "receiveAll",
  }]
  });



  useEffect(() => {
    if (connectedAddress) {
      fetchBalance();
    }
  }, [connectedAddress]);

  // const fetchBalance = async () => {
  //   const addr=connectedAddress;
  //   await axios
  //     .post("/api/check", {
  //       addr
  //     })
  //     .then((res) => {
  //       setBalance(res.data);
  //     });

  // };

  const fetchBalance = async () => {
    const addr = connectedAddress;
    const formData = new FormData();
    formData.append("addr", String(addr));
  
    await axios
      .post("/api/check", formData)
      .then((res) => {
        setBalance(res.data);
      })
      .catch((error) => {
        console.error("Failed to fetch balance:", error);
      });
  };

  const claimReward = async () => {
    try {
      await receiveAll();
      alert("Reward claimed successfully!");
    } catch (error) {
      console.error("Failed to claim reward:", error);
      alert("Failed to claim reward.");
    }
  };

  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center">
            <span className="block text-2xl mb-2">Welcome to</span>
            <span className="block text-4xl font-bold">Devdock</span>
          </h1>
          <div className="flex justify-center items-center space-x-2">
            <p className="my-2 font-medium">Connected Address:</p>
            <Address address={connectedAddress as AddressType} />
          </div>
          <div className="flex justify-center items-center space-x-2">
            <p className="my-2 font-medium">Unclaimed reward:</p>
            <p>{balance !== null ? `${balance}  STRK` : "Loading..."}</p>
          </div>
          <button
            className="mt-4 px-4 py-2 bg-blue-500 text-white rounded"
            onClick={claimReward}
          >
            Claim my reward
          </button>
        </div>
      </div>
    </>
  );
};

export default Home;
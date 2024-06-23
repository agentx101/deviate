"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { Address } from "~~/components/scaffold-stark";
import { useAccount } from "@starknet-react/core";
import { Address as AddressType } from "@starknet-react/chains";
import { useState, useEffect } from "react";
import { useScaffoldReadContract } from "~~/hooks/scaffold-stark/useScaffoldReadContract";
import { useDeployedContractInfo, useTransactor } from "~~/hooks/scaffold-stark";
import { useContractRead, useNetwork } from "@starknet-react/core";
import { useScaffoldMultiWriteContract } from "~~/hooks/scaffold-stark/useScaffoldMultiWriteContract";
import axios from "axios";
import { useTargetNetwork } from "~~/hooks/scaffold-stark/useTargetNetwork";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const [balance, setBalance] = useState<number | null>(null);
  const [leaderboard, setLeaderboard] = useState<{ address: string, balance: number }[]>([]);

  const { writeAsync: receiveAll } = useScaffoldMultiWriteContract({
    calls: [{
      contractName: "DevDock",
      functionName: "receiveAll",
    }]
  });

  useEffect(() => {
    if (connectedAddress) {
      fetchBalance(connectedAddress, setBalance);
      fetchLeaderboard();
    }
  }, [connectedAddress]);

  const fetchBalance = async (addr: string, setBalanceCallback: (balance: number) => void) => {
    const formData = new FormData();
    formData.append("addr", String(addr));
  
    await axios
      .post("/api/check", formData)
      .then((res) => {
        setBalanceCallback(res.data);
      })
      .catch((error) => {
        console.error("Failed to fetch balance:", error);
      });
  };

  const fetchLeaderboard = async () => {
    const additionalAddresses = [
      "0x03CcB4fc530BB6Fb24B2a8c2A6ca5AA418a25A2320630a9d4a78A9d141D5868E",
      "0x012Fd07B2e4C6106CDE68a05E7A77E92eF629a59A3F819A9EE864c1f2469f356",
      "0x07D5F750dB640AbDC67b75D593BB6Fb515B67e07f27336266F3CB5c301c657eF",
      "0x049ee2B5d1Fb4b48d2437605A747B6974EdD2518CaBde513f3e7C4855E270227",
      "0x0044A4bE0225bDa4199337D7910374b512fedd65E5B7a366035FdC3268C349C6",
    ];

    const leaderboardData = await axios
      .get("/api/leaderboard")
      .then((res) => res.data)
      .catch((error) => {
        console.error("Failed to fetch leaderboard:", error);
        return [];
      });

    const updatedLeaderboard = await Promise.all(
      additionalAddresses.map(async (address) => {
        let balance = 0;
        await fetchBalance(address, (fetchedBalance) => {
          balance = fetchedBalance;
        });
        return { address, balance };
      })
    );

    const finalLeaderboard = [...leaderboardData, ...updatedLeaderboard];
    finalLeaderboard.sort((a, b) => b.balance - a.balance);
    setLeaderboard(finalLeaderboard);
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
          {/* <div className="flex justify-center items-center space-x-2">
            <p className="my-2 font-medium">Connected Address:</p>
            <Address address={connectedAddress as AddressType} />
          </div> */}
          <div className="flex justify-center items-center space-x-2">
            <p className="my-2 font-medium text-3xl">Unclaimed reward:</p>
            <p className="text-3xl">{balance !== null ? `${balance} STRK` : "Loading..."}</p>
          </div>
          <button
            className="mt-4 px-8 py-4 bg-orange-500 text-white rounded text-lg align-center"
            onClick={claimReward}
          >
            Claim my reward
          </button>
          <div className="mt-10">
            <h2 className="text-2xl font-bold mb-4">Leaderboard</h2>
            <table className="min-w-full bg-green-700">
              <thead>
                <tr>
                  <th className="py-2 px-4 border-b">Rank</th>
                  <th className="py-2 px-4 border-b">Wallet Address</th>
                  <th className="py-2 px-4 border-b">Unclaimed Tokens</th>
                </tr>
              </thead>
              <tbody>
                {leaderboard.map((entry, index) => (
                  <tr key={entry.address}>
                    <td className="py-2 px-4 border-b">{index + 1}</td>
                    <td className="py-2 px-4 border-b">{entry.address}</td>
                    <td className="py-2 px-4 border-b">{entry.balance} STRK</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
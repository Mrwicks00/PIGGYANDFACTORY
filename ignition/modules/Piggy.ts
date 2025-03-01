// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const piggyModule = buildModule("piggyModule", (m) => {
  const piggy = m.contract("PiggyFactory" []);

  return { piggy };
});

export default piggyModule;

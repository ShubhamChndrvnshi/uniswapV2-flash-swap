import { ethers } from "hardhat";

export async function main() {

  const FACTORY: string = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
  const ROUTER: string = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  const WETH: string = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";


  const UniswapFlashSwapManager = await ethers.getContractFactory("UniswapFlashSwapManager");
  const uniswapFlashSwapManager = await UniswapFlashSwapManager.deploy(ROUTER, FACTORY, WETH);

  await uniswapFlashSwapManager.deployed();

  console.log(`UniswapFlashSwapManager deployed to ${uniswapFlashSwapManager.address}`);
  return uniswapFlashSwapManager.address;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

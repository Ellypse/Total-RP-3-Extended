----------------------------------------------------------------------------------
-- Total RP 3: Quest DB
-- ---------------------------------------------------------------------------
-- Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------------

local DB_TEXTS = {
	doc1 = [[{h1}Contract for job{/h1}
The Valley of Northsire is under the attack of an armed group of orcs and gobelins.
The King is offering rewards to any brave soldiers willing to take the arms

If you want to help protecting your lands, please talk to an Army Registrar in front on the abbey.

For the King,
Marshal McBride





{img:Interface\PvPRankBadges\PvPRankAlliance.blp:128:128}]]
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CAMPAIGN DB
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local demoCampaign = {
	TY = TRP3_DB.types.CAMPAIGN,

	MD = {
		["CD"] = "26/05/16 11:42:07",
		["CB"] = "TRP3 Team",
		["SB"] = "TRP3 Team",
		["MO"] = "EX",
		["SD"] = "19/06/16 16:14:15",
		["V"] = 44,
	},

	-- Base information, common to the whole campaign
	BA = {
		IC = "spell_arcane_arcaneresilience",
		NA = "Save Northshire Valley",
		DE = "Take the arms and defend the abbey. Take the arms and defend the abbey. Take the arms and defend the abbey. Take the arms and defend the abbey. Take the arms and defend the abbey. Take the arms and defend the abbey. Take the arms and defend the abbey. Take the arms and defend the abbey. Take the arms and defend the abbey.",
		RA = "1 - 5",
		IM = "GarrZoneAbility-MageTower",
	},

	-- Initial campaign NPC declaration
	ND = {
		["196"] = {
			IC = "inv_misc_1h_lumberaxe_a_01",
			NA = "Mysterious lumberjack",
			DE = "Who could be this guy ?"
		}
	},

	QE = {
		["quest1"] = {
			TY = TRP3_DB.types.QUEST,

			-- Base information, common to the whole quest
			BA = {
				IC = "ability_warrior_strengthofarms",
				NA = "To arms!",
				DE = "Succeed the registration test.",
			},

			-- Objectives
			OB = {
				["1"] = {
					TX = "Talk to a Stormwind Army Registrar",
				},
			},

			-- Inner objects
			IN = {
				recruitementDoc = {
					TY = TRP3_DB.types.DOCUMENT,
					BA = {
						NA = "Recruitement missive"
					},
					PA = {
						{
							TX = DB_TEXTS.doc1,
						}
					},
				}
			},

			-- Scripts for quest
			SC = {
				["QUEST_START"] = {
					ST = {
						["1"] = {
							t = "list",
							e = {
								{
									id = "document_show",
									args = { "demoCampaign quest1 recruitementDoc" }
								},
								{
									id = "quest_goToStep",
									args = { "demoCampaign", "quest1", "1" }
								},
							}
						},
					},
				},
			},

			-- OnStart inner handler
			OS = "QUEST_START",

			-- Quest steps
			ST = {
				--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				-- Quest step 1: Talk to a registrar
				--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

				["1"] = {
					TY = TRP3_DB.types.QUEST_STEP,

					-- Quest step log information ONCE IN STEP
					TX = "I should talk to a |cffffff00[Stormwind Army Registrar]|r in front of the Northshire Abbey.",
					-- Quest step log information ONCE FINISHED
					DX = "I talked to an Army Registrar.",

					AC = {
						TALK = { "REGISTRAR_TALK" },
					},

					-- Scripts for quest
					SC = {
						["STEP_START"] = {
							ST = {
								["1"] = {
									t = "list",
									e = {
										{
											id = "quest_revealObjective",
											args = { "demoCampaign", "quest1", "1" }
										},
									}
								},
							},
						},
						["REGISTRAR_TALK"] = {
							ST = {
								["1"] = {
									t = "list",
									e = {
										{
											id = "dialog_start",
											args = { "demoCampaign quest1 1 dialog" }
										},
										{
											id = "quest_goToStep",
											args = { "demoCampaign", "quest1", "2" }
										},
									}
								},
							},
						},
					},
					IN = {
						history = {
							TY = TRP3_DB.types.DIALOG,
							BG = "Interface\\ARCHEOLOGY\\Arch-BookCompletedLeft",
							NM = "The Elder's Voice",
							ST = {
								{
									TX = "<And when the child put his hand on the stone, it glowed like a thousand fire ...>\n<But he knew he would be curse if he'd had taken the scepter.>",
									IM = {
										UR = "Interface\\ARCHEOLOGY\\ArchRare-TheInnKeepersDaughter",
										WI = 1024,
										HE = 512
									},
									ND = "LEFT",
								},

								{
									TX = "<As the Scepter is filled with black magic.>",
									IM = {
										UR = "Interface\\ARCHEOLOGY\\ArchRare-StaffofSorcererThanThaurissan",
										WI = 512,
										HE = 256
									},
									ND = "LEFT",
								},

								{
									TX = "<Only queen Azshara did succeed in handling such terrible power.>\n<And everobody knows how it ended...>",
									IM = {
										UR = "Interface\\ARCHEOLOGY\\ArchRare-QueenAzsharaGown",
										WI = 1024,
										HE = 512
									},
									ND = "LEFT",
								},
							},
						},
						dialog = {
							TY = TRP3_DB.types.DIALOG,
							ST = {
								{
									-- 1
									TX = "Hello, I'm here for the job.",
									ND = "LEFT"
								},

								{
									-- 2
									TX = "Ah yes, the job about the orcs. We need to kill them all and free Northshire.\nBut it won't be an easy task.\nFirst we need wood to be able to craft some weapons. Could you talk to John ? He's a lumberjack here in Northshire.",
								},
							}
						}
					},

					-- OnStart inner handler
					OS = "STEP_START",
				},

				["2"] = {
					TY = TRP3_DB.types.QUEST_STEP,

					-- Quest step log information ONCE IN STEP
					TX = "I should talk to the |cffffff00[Lumber jack]|r in front of the Northshire Abbey.",

					-- Initial campaign NPC declaration
					ND = {
						["196"] = {
							IC = "inv_misc_1h_lumberaxe_a_01",
							NA = "Jack",
							DE = "It's Jack the lumberjack!\n(pun intended)"
						}
					},
				}
			},
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Actions & script
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Scripts for campaign
	SC = {
		["CAMPAIGN_START"] = {
			ST = {
				["1"] = {
					t = "list",
					e = {
						{
							id = "quest_start",
							args = { "demoCampaign", "quest1" }
						},
					}
				},
			},
		},
	},

	-- OnStart inner handler
	LI = {
		OS = "CAMPAIGN_START"
	}
};
--TRP3_DB.inner.demoCampaign = demoCampaign;

local myFirstCampaign = {
	TY = TRP3_DB.types.CAMPAIGN,

	MD = {
		["CD"] = "26/05/16 11:42:07",
		["CB"] = "TRP3 Team",
		["SB"] = "TRP3 Team",
		["MO"] = "EX",
		["SD"] = "19/06/16 16:14:15",
		["V"] = 44,
	},

	-- Base information, common to the whole campaign
	BA = {
		IC = "achievement_reputation_05",
		NA = "A dangerous friendship",
		DE = "Looking for some easy money?\Be careful, some friendship can became dangerous...",
		IM = "GreenstoneKeg",
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Quest list
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	QE = {
		["quest1"] = {
			TY = TRP3_DB.types.QUEST,

			-- Base information, common to the whole quest
			BA = {
				IC = "INV_jewelcrafting_Empyreansapphire_02",
				NA = "The first job",
				DE = "An Night Elf in Stormwind asks for help, so it's the good time to work.",
			},

			-- Different objective from all steps
			-- OB only contains information, no script trigger !
			OB = {
				-- Boolean objective: simple activation
				["1"] = {
					TX = "Find Kyle Radue.",
				},
				["2"] = {
					TX = "Read and sign the contract.",
				},

				-- Count objective: do something a certain amount of time
				["x"] = {
					TX = "{val} / {obj} kobold killed",
					CT = 25,
				},

				-- Component objective: must possess a certain amount of a component
				["xx"] = {
					TX = "My seconde objective: {cur} / {obj}",
					CO = "quest1	2	jewel", -- tabs separate the id domains
					CT = 5,
				},
			},

			-- Scripts for quest
			SC = {
				["QUEST_START"] = {
					ST = {
						["1"] = {
							t = "list",
							e = {
								{
									id = "quest_goToStep",
									args = { "myFirstCampaign", "quest1", "1" }
								},
							}
						},
					},
				},
			},

			-- OnStart inner handler
			OS = "QUEST_START",

			-- Quest steps
			ST = {
				--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				-- Quest step 1: Found the elf
				--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

				["1"] = {
					TY = TRP3_DB.types.QUEST_STEP,

					-- Quest step log information ONCE IN STEP
					TX = "I should find the Night Elf. He's name is Kyle Radue. He should be in the Canals in Stormwind.",

					-- Quest step log information ONCE FINISHED
					DX = "I found the Elf in the Storwind Canals.",
					AC = {
						TALK = { "FOUND_KYLE" },
					},

					-- Scripts for this step
					SC = {
						["STEP_START"] = {
							ST = {
								-- 1: add objective 1
								["1"] = {
									t = "list",
									e = {
										{
											id = "quest_revealObjective",
											args = { "myFirstCampaign", "quest1", "1" }
										},
									}
								},
							},
						},
						["FOUND_KYLE"] = {
							ST = {
								-- 1: add objective 1
								["1"] = {
									t = "branch",
									b = {
										{
											cond = { { { i = "tar_name" }, "==", { v = "Kyle Radue" } } },
											n = "2"
										}
									},
								},
								["2"] = {
									t = "list",
									e = {
										{
											id = "quest_markObjDone",
											args = { "myFirstCampaign", "quest1", "1" }
										},
										{
											id = "quest_goToStep",
											args = { "myFirstCampaign", "quest1", "2" }
										},
									}
								},
							},
						}
					},

					-- Inner object
					IN = {
						firstPay = {
							TY = TRP3_DB.types.LOOT,
							IC = "inv_box_01",
							NA = "A first pay",
							IT = {
								["1"] = {
									id = "coin1",
									count = 10,
								}
							}
						}
					},

					-- OnStart inner handler
					OS = "STEP_START",
				},

				--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				-- Quest step 2: Read the contract and sign it
				--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

				["2"] = {
					TY = TRP3_DB.types.QUEST_STEP,

					-- Quest step log information ONCE IN STEP
					TX = "Kyle gave me a contract that I should read carefully and sign.",

					-- Quest step log information ONCE FINISHED
					DX = "I signed the contract.",

					-- Scripts for this step
					SC = {
						["STEP_START"] = {
							ST = {
								-- 1: add objective 1
								["1"] = {
									t = "list",
									e = {
										{
											id = "text",
											args = { "Kyle says: Hello, take this contract and sign it.", 1 }
										},
										{
											id = "quest_revealObjective",
											args = { "myFirstCampaign", "quest1", "2" }
										},
										{
											id = "item_loot",
											args = { "myFirstCampaign quest1 2 contractLoot" }
										},
									}
								},
							},
						},
					},
					AC = {
						TALK = { "STEP_START" },
					},

					-- OnStart inner handler
					OS = "STEP_START",

					-- Inner objects
					IN = {
						contractLoot = {
							TY = TRP3_DB.types.LOOT,
							IC = "inv_box_01",
							NA = "Quickloot",
							IT = {
								["1"] = {
									id = "myFirstCampaign quest1 2 contractItem",
									count = 1,
								}
							}
						},

						-- Document item
						contractItem = {
							TY = TRP3_DB.types.ITEM,
							BA = {
								IC = "inv_misc_toy_05",
								NA = "Contract",
								DE = "A simple contract, written on paper.",
								UN = 1,
								WE = 0.1,
							},
							US = {
								AC = "Read the contract",
								SC = "quest"
							},
							SC = {
								quest = {
									ST = {
										["1"] = {
											t = "list",
											e = {
												{
													id = "document_show",
													args = { "myFirstCampaign quest1 2 contractDoc" }
												},
											}
										}
									}
								}
							}
						},

						-- Document
						contractDoc = {
							TY = TRP3_DB.types.DOCUMENT,
							BA = {
								NA = "Contract"
							},
							PA = {
								{
									TX = DB_TEXTS.doc1,
								}
							},
							AC = {
								sign = "sign",
							},
							SC = {
								["sign"] = {
									ST = {
										["1"] = {
											t = "list",
											e = {
												{
													id = "document_close",
													args = { "myFirstCampaign quest1 2 contractDoc" }
												},
												{
													id = "quest_markObjDone",
													args = { "myFirstCampaign", "quest1", "2" }
												},
												{
													id = "quest_goToStep",
													args = { "myFirstCampaign", "quest1", "3" }
												},
											}
										},
									},
								},
							}
						}
					},
				},

				--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				-- Quest step 3: Reward
				--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

				["3"] = {
					TY = TRP3_DB.types.QUEST_STEP,

					-- Scripts for this step
					SC = {
						["STEP_START"] = {-- 1: Show dialog REWARD
						},
					},

					-- OnStart inner handler
					--						OS = "STEP_START",
				},
			},
		}
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Actions & script
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Scripts for campaign
	SC = {
		["CAMPAIGN_START"] = {
			ST = {
				["1"] = {
					t = "list",
					e = {
						{
							id = "quest_start",
							args = { "myFirstCampaign", "quest1" }
						},
					}
				},
			},
		},
	},

	-- OnStart inner handler
	LI = {
		OS = "CAMPAIGN_START"
	}
};
--TRP3_DB.inner.myFirstCampaign = myFirstCampaign;
using System.ComponentModel;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
    public class CraftingRecipe : ScriptableObject
    {
        public List<ItemAmount> materials;
        Player _player;
        private Inventory _inventory;
        public int buildAmount = 0;
        public List<ItemAmount> results;
        Vector3 auxVector;

        [Serializable]
        public struct ItemAmount
        {
            //public InventoryItem item;
            public int craftingID;
            public int amount;
            public Sprite itemImage;
            public GameObject trapPrefab;
        }
        
        public bool HasBaseballTrapItems(Inventory inventory)
        {
            return inventory.ContainsID(5) && inventory.ContainsID(2) && inventory.ContainsID(8);
        }
        public bool HasTVTrapItems(Inventory inventory)
        {
            return inventory.ContainsID(2) && inventory.ContainsID(6);
        }

        public bool HasSlowTrapItems(Inventory inventory)
        {
            return inventory.ContainsID(4);
        }

        public bool CanCraft(Inventory inventory)
        {
            _inventory = inventory;
            foreach (ItemAmount itemAmount in materials)
            {
                
                if(!inventory.ContainsID(itemAmount.craftingID))
                {
                    return false;
                }
            }
            return true;           
        }

        public void Craft(Inventory inventory)
        {
            if (CanCraft(inventory))
            {
                foreach(ItemAmount itemAmount in results)
                {
                    for (int i = 0; i < itemAmount.amount; i++)
                    {
                        _player = GameObject.Find("Player").GetComponent<Player>();
                        
                        if(buildAmount == 0)
                        {
                            //GameObject aux = Instantiate(itemAmount.trapPrefab, _player.GetPrefabPlacement(), Quaternion.Euler(-90f,0f,90f));
                            //GameObject aux = Instantiate(itemAmount.trapPrefab, _player.GetPrefabPlacement(), Quaternion.identity);
                            _player.SwitchIsCrafting();
                            GameObject aux = Instantiate(itemAmount.trapPrefab, GameVars.Values.GetPlayerPrefabPlacement(), Quaternion.identity);
                            aux.transform.eulerAngles = new Vector3(aux.transform.eulerAngles.x, GameVars.Values.GetPlayerCameraRotation(), aux.transform.eulerAngles.z);
                        }
                        buildAmount++;
                    }                    
                }
            }
        }

        public void RemoveItems()
        {
            foreach(ItemAmount itemAmount in materials)
                {
                    for(int i = 0; i < itemAmount.amount; i++)
                    {
                        _inventory.RemoveItemID(itemAmount.craftingID);
                    }
                }
        }

        public void RestoreBuildAmount()
        {
            buildAmount = 0;
        }
    }
    


   



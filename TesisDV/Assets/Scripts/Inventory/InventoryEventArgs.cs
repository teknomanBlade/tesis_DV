using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventoryEventArgs : EventArgs
{
    public InventoryEventArgs(InventoryItem item)
    {
        Item = item;
    }   

    public InventoryItem Item;
}

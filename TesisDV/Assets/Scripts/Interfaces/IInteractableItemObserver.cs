using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IInteractableItemObserver 
{
    void OnNotify(string message);
}

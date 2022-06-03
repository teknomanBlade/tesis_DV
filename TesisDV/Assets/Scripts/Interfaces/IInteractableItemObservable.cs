using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IInteractableItemObservable 
{
    void AddObserver(IInteractableItemObserver obs);
    void RemoveObserver(IInteractableItemObserver obs);
    void TriggerInteractableItem(string triggerMessage);
}

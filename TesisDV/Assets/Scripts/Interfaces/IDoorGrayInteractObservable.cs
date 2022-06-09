using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDoorGrayInteractObservable
{
    void AddObserverDoorGrayInteract(IDoorGrayInteractObserver obs);
    void RemoveObserverDoorGrayInteract(IDoorGrayInteractObserver obs);
    void TriggerDoorGrayInteract(string triggerMessage);
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IRoundChangeObservable 
{
    void AddObserver(IRoundChangeObserver obs);
    void RemoveObserver(IRoundChangeObserver obs);
    void TriggerRoundChange(string triggerMessage);
}

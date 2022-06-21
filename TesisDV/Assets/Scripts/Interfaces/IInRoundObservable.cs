using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IInRoundObservable
{ 
    void AddObserverInRound(IInRoundObserver obs);
    void RemoveObserverInRound(IInRoundObserver obs);
    void TriggerHitInRound(string triggerMessage);
}

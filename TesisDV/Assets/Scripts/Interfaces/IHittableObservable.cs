using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IHittableObservable
{
    void AddObserver(IHittableObserver obs);
    void RemoveObserver(IHittableObserver obs);
    void TriggerHit(string triggerMessage);
}

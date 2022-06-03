using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IPlayerDamageObservable
{
    void AddObserver(IPlayerDamageObserver obs);
    void RemoveObserver(IPlayerDamageObserver obs);
    void TriggerPlayerDamage(string triggerMessage);
}

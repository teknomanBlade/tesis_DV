using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IPlayerDamageObserver
{
    void OnNotifyPlayerDamage(string message);
}

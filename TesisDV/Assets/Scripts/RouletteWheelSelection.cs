using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RouletteWheelSelection
{
    Dictionary<string, int> littleRoulette;
    int _totalWeight;

    public RouletteWheelSelection()
    {
        littleRoulette = new Dictionary<string, int>();
        littleRoulette.Add("NORMAL", 5);
        littleRoulette.Add("FAST", 25);
        littleRoulette.Add("TANK", 40);

        foreach (var action in littleRoulette)
        {
            _totalWeight += action.Value;
        }

    }

    public KeyValuePair<string, int> RouletteSelection()
    {
        int randomValue = Random.Range(0, _totalWeight);
        foreach (var item in littleRoulette)
        {
            randomValue -= item.Value;

            if (randomValue < 0)
            {
                return item;
            }
        }
        return new KeyValuePair<string, int>();
    }

}

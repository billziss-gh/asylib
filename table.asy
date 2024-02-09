/*
 * table.asy
 *
 * Copyright 2024 Bill Zissimopoulos
 */
/*
 * MIT License
 *
 * Copyright (c) 2024 Bill Zissimopoulos
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import three;

// A table consists of columns; each column has a name and a series or real or string values.
struct table
{
    struct column
    {
        string name;
        real[] rval;
        string[] sval;
        void operator init(string name, real[] rval)
        {
            this.name = name;
            this.rval = rval;
        }
        void operator init(string name, string[] sval)
        {
            this.name = name;
            this.sval = sval;
        }
    };
    column[] columns;
    void addcolumn(string name, real[] rval)
    {
        this.columns.push(column(name, rval));
    }
    void addcolumn(string name, string[] sval)
    {
        this.columns.push(column(name, sval));
    }
};

private bool dbgdot = false;
private void dbgdot(picture pic, pair position, pen p)
{
    if (!dbgdot)
        return;
    dot(pic, position, p);
}
private void dbgdot(picture pic, triple position, pen p)
{
    if (!dbgdot)
        return;
    dot(pic, position, p);
}

// Draw a table in 2-dimensional space.
void draw(
    picture pic=currentpicture,
    string name="",
    table table,
    pair position,
    pair unitsize=(1, 1),
    string realfmt="$%#.2f$",
    real[] colwidths={ 1.0 },
    real colmargin=0,
    pen p=currentpen,
    pen[] colfillpens={},
    pen[] rowfillpens={},
    string borders="NNEWS",
    pair align=(0, 0))
{
    int ncols = table.columns.length;
    if (0 == ncols)
        return;

    int nrows = table.columns[0].rval.length + table.columns[0].sval.length;
    int trows = nrows + ("" == name ? 1 : 2);

    real[] colwid = new real[ncols];
    for (int j = 0; ncols > j; ++j)
        colwid[j] = colwidths.length > j ? colwidths[j] : colwidths[colwidths.length - 1];

    real[] colpos = new real[ncols + 1];
    colpos[0] = 0.0;
    for (int j = 0; ncols > j; ++j)
        colpos[j + 1] = colpos[j] + colwid[j] + colmargin;
    colpos[ncols] -= colmargin;

    transform t =
        shift(position) *
        scale(unitsize.x, unitsize.y) *
        shift((sgn(align.x) - 1) * colpos[ncols] / 2, (sgn(align.y) - 1) * trows / 2);

    for (int j = 0; ncols > j && colfillpens.length > j; ++j)
        if (nullpen != colfillpens[j])
            fill(pic, t * box((colpos[j], 0), (colpos[j] + colwid[j], nrows)), colfillpens[j]);
    for (int i = 0; nrows > i && rowfillpens.length > i; ++i)
        if (nullpen != rowfillpens[i])
            fill(pic, t * box((0, nrows - i - 1), (colpos[ncols], nrows - i)), rowfillpens[i]);

    if (0 <= find(borders, "NN"))
        draw(pic, t * ((0, nrows + 1) -- (colpos[ncols], nrows + 1)), p=p);
    if (0 <= find(borders, "N"))
        draw(pic, t * ((0, nrows) -- (colpos[ncols], nrows)), p=p);
    if (0 <= find(borders, "E"))
        draw(pic, t * ((colpos[ncols], 0) -- (colpos[ncols], nrows + 1)), p=p);
    if (0 <= find(borders, "W"))
        draw(pic, t * ((0, 0) -- (0, nrows + 1)), p=p);
    if (0 <= find(borders, "S"))
        draw(pic, t * ((0, 0) -- (colpos[ncols], 0)), p=p);

    if ("" != name)
    {
        label(pic, name, t * (colpos[ncols] / 2, nrows + 1), p=p, align=N);
        dbgdot(pic, t * (colpos[ncols] / 2, nrows + 1), blue);
    }

    for (int j = 0; ncols > j; ++j)
        if (0 < table.columns[j].rval.length)
        {
            label(pic,
                table.columns[j].name,
                t * (colpos[j] + colwid[j], nrows),
                p=p, align=NW);
            dbgdot(pic, t * (colpos[j] + colwid[j], nrows), green);
            for (int i = 0; nrows > i; ++i)
            {
                real rval = table.columns[j].rval.length > i ?
                    table.columns[j].rval[i] : table.columns[j].rval[table.columns[j].rval.length - 1];
                label(pic,
                    format(realfmt, rval),
                    t * (colpos[j] + colwid[j], nrows - i - 1),
                    p=p, align=NW);
                dbgdot(pic, t * (colpos[j] + colwid[j], nrows - i - 1), green);
            }
        }
        else if (0 < table.columns[j].sval.length)
        {
            label(pic,
                table.columns[j].name,
                t * (colpos[j], nrows),
                p=p, align=NE);
            dbgdot(pic, t * (colpos[j], nrows), blue);
            for (int i = 0; nrows > i; ++i)
            {
                string sval = table.columns[j].sval.length > i ?
                    table.columns[j].sval[i] : table.columns[j].sval[table.columns[j].sval.length - 1];
                label(pic,
                    sval,
                    t * (colpos[j], nrows - i - 1),
                    p=p, align=NE);
                dbgdot(pic, t * (colpos[j], nrows - i - 1), blue);
            }
        }
}

// Draw a table in 3-dimensional space.
void draw(
    picture pic=currentpicture,
    string name="",
    table table,
    triple position,
    pair unitsize=(1, 1),
    string realfmt="$%#.2f$",
    real[] colwidths={ 1.0 },
    real colmargin=0,
    pen p=currentpen,
    pen[] colfillpens={},
    pen[] rowfillpens={},
    string borders="NNEWS",
    pair align=(0, 0),
    pen fillpen=nullpen)
{
    int ncols = table.columns.length;
    if (0 == ncols)
        return;

    int nrows = table.columns[0].rval.length + table.columns[0].sval.length;
    int trows = nrows + ("" == name ? 1 : 2);

    real[] colwid = new real[ncols];
    for (int j = 0; ncols > j; ++j)
        colwid[j] = colwidths.length > j ? colwidths[j] : colwidths[colwidths.length - 1];

    real[] colpos = new real[ncols + 1];
    colpos[0] = 0.0;
    for (int j = 0; ncols > j; ++j)
        colpos[j + 1] = colpos[j] + colwid[j] + colmargin;
    colpos[ncols] -= colmargin;

    transform3 t =
        shift(position) *
        scale(unitsize.x, unitsize.y, 1) *
        shift((sgn(align.x) - 1) * colpos[ncols] / 2, (sgn(align.y) - 1) * trows / 2, 0);

    if (nullpen != fillpen)
        draw(surface(shift(0, 0, -0.0003) * t * path3(box((0, 0), (colpos[ncols], nrows + 2)))), fillpen, nolight);

    for (int j = 0; ncols > j && colfillpens.length > j; ++j)
        if (nullpen != colfillpens[j])
            draw(surface(shift(0, 0, -0.0002) * t * path3(box((colpos[j], 0), (colpos[j] + colwid[j], nrows)))), colfillpens[j], nolight);
    for (int i = 0; nrows > i && rowfillpens.length > i; ++i)
        if (nullpen != rowfillpens[i])
            draw(surface(shift(0, 0, -0.0001) * t * path3(box((0, nrows - i - 1), (colpos[ncols], nrows - i)))), rowfillpens[i], nolight);

    if (0 <= find(borders, "NN"))
        draw(pic, t * ((0, nrows + 1, 0) -- (colpos[ncols], nrows + 1, 0)), p=p);
    if (0 <= find(borders, "N"))
        draw(pic, t * ((0, nrows, 0) -- (colpos[ncols], nrows, 0)), p=p);
    if (0 <= find(borders, "E"))
        draw(pic, t * ((colpos[ncols], 0, 0) -- (colpos[ncols], nrows + 1, 0)), p=p);
    if (0 <= find(borders, "W"))
        draw(pic, t * ((0, 0, 0) -- (0, nrows + 1, 0)), p=p);
    if (0 <= find(borders, "S"))
        draw(pic, t * ((0, 0, 0) -- (colpos[ncols], 0, 0)), p=p);

    if ("" != name)
    {
        label(pic, XY * name, t * (colpos[ncols] / 2, nrows + 1, 0), p=p, align=N);
        dbgdot(pic, t * (colpos[ncols] / 2, nrows + 1, 0), blue);
    }

    for (int j = 0; ncols > j; ++j)
        if (0 < table.columns[j].rval.length)
        {
            label(pic,
                XY * table.columns[j].name,
                t * (colpos[j] + colwid[j], nrows, 0),
                p=p, align=NW, interaction=Embedded);
            dbgdot(pic, t * (colpos[j] + colwid[j], nrows, 0), green);
            for (int i = 0; nrows > i; ++i)
            {
                real rval = table.columns[j].rval.length > i ?
                    table.columns[j].rval[i] : table.columns[j].rval[table.columns[j].rval.length - 1];
                label(pic,
                    XY * format(realfmt, rval),
                    t * (colpos[j] + colwid[j], nrows - i - 1, 0),
                    p=p, align=NW, interaction=Embedded);
                dbgdot(pic, t * (colpos[j] + colwid[j], nrows - i - 1, 0), green);
            }
        }
        else if (0 < table.columns[j].sval.length)
        {
            label(pic,
                XY * table.columns[j].name,
                t * (colpos[j], nrows, 0),
                p=p, align=NE, interaction=Embedded);
            dbgdot(pic, t * (colpos[j], nrows, 0), blue);
            for (int i = 0; nrows > i; ++i)
            {
                string sval = table.columns[j].sval.length > i ?
                    table.columns[j].sval[i] : table.columns[j].sval[table.columns[j].sval.length - 1];
                label(pic,
                    XY * sval,
                    t * (colpos[j], nrows - i - 1, 0),
                    p=p, align=NE, interaction=Embedded);
                dbgdot(pic, t * (colpos[j], nrows - i - 1, 0), blue);
            }
        }
}


/*
 * Testing
 */

if (false)
{
    // 2D test

    table t;
    t.addcolumn("$P$", new real[] { 188.63, 191.56, 193.89, 195.18, 194.5, 194.17, 192.42, 191.73, 188.04, 184.4 });
    t.addcolumn("$V$", new real[] { 77.92, 68.74, 60.1, 42.3, 53.58, 54.73, 44.55, 47.04, 55.75, 55.4 });
    t.addcolumn("$S$", new real[] { 0.23, 0.43, 0.17, 0.35, 0.48, 0.11, -0.02, 0.05, 0.19, 0.09 });
    t.addcolumn("$str$", new string[] { "foo", "bar" });

    unitsize(1cm);
    draw(t, (0, 0),
        name="AAPL", unitsize=(1, 0.5), colwidths=new real[] { 2 }, colmargin=0.5,
        colfillpens=new pen[] { pink, palegreen, palecyan, pink },
        rowfillpens = new pen[] { nullpen, paleblue, lightblue });
    dot((0, 0), red);
    shipout(bbox(0.25cm));
}
else if (false)
{
    // 3D test

    table t;
    t.addcolumn("$P$", new real[] { 188.63, 191.56, 193.89, 195.18, 194.5, 194.17, 192.42, 191.73, 188.04, 184.4 });
    t.addcolumn("$V$", new real[] { 77.92, 68.74, 60.1, 42.3, 53.58, 54.73, 44.55, 47.04, 55.75, 55.4 });
    t.addcolumn("$S$", new real[] { 0.23, 0.43, 0.17, 0.35, 0.48, 0.11, -0.02, 0.05, 0.19, 0.09 });
    t.addcolumn("$str$", new string[] { "foo", "bar" });

    unitsize(1cm);
    currentprojection = orthographic((-1, 1, 1), up=Y);
    draw(t, (0, 0, 0),
        name="AAPL", unitsize=(1, 0.5), colwidths=new real[] { 2 }, colmargin=0.5,
        colfillpens=new pen[] { pink, palegreen, palecyan, pink },
        rowfillpens = new pen[] { nullpen, paleblue, lightblue },
        fillpen=lightgray);
    dot((0, 0, 0), red);
    shipout(bbox(0.25cm));
}
